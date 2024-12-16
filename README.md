# Case study for learning language-specific layers in MMTL

In this case study I am basically reproducing 

```{bibtex}
@article{pires2023learning,
  title={Learning language-specific layers for multilingual machine translation},
  author={Pires, Telmo Pessoa and Schmidt, Robin M and Liao, Yi-Hsiu and Peitz, Stephan},
  journal={arXiv preprint arXiv:2305.02665},
  year={2023}
}
```

In a most extreme straight forward approach one would train a multilingual model with non-shared encoders and decoders. However this does not scale well 
for adding more language pairs, in terms of model capacity and slow inference.
Thus, the authors propose the use of Language-Specific Transformer Layers (**LSL**s), especially in the encoder block, in order to gain in model capacity and
computation time.
The idea of the proposed LSL architecture is to have share large parts of the encoder and the whole decoder across language and only introduce language specificity when needed. This is achieve by replacing an otherwise shared Transformer block with an LSL which takes the given language pair into account.

In my little case study provide all necessary scripts from fetching the data to generating from the trained LSL model. The code can be found in the `mmtl`folder.

The following scripts are tooled via a .env file, I include a template so that it can be fed with the environment variables needed by the scripts.

## Data preparation

For training I will stick to the tatoeba and wmt21 dataset, i.e., as opposed to the original publication I will omit the CCMatrix and Opus-101 dataset.
For validation and test I will use the Flores 200 dataset, analogously to the used Flores 101 dataset used in the original publication.

### Fetching raw data

For each dataset there is a script in `mmtl/scripts/raw_data`. I downloaded the Flores dataset manually, tatoeaba and wmt21 are fetched directly from within the scripts.
Due to inconsistent naming conventions these scripts also bring everything to a consistent
format, which is given as `dataset.lang_pair.src` and `dataset.lang_pair.tgt`, e.g. 
`wmt21.en-de.de`.

Furthermore, I restrict to the language pairs (always both translate directions): `de-fr, en-de, en-ja, zh-en`.

### Training Tokenizer

Following the suggestions of the publication, I train a sentencepiece tokenizer on tatoeba and
wmt21, where I balance the huge tatoeba set in step to subsamples of 1.5M sentences.
This subsampling is performed in `mmtl/scripts/train_encode/subsample.sh`.
The subsampling  relies on the nice subsample CLI https://github.com/dcjones/subsample/tree/master 

The tokenizer is trained on 16 threads via `mmtl/scripts/train_encode/train_encode.sh` providing us
with `MMTL_spm.model` and `MMTL_spm.vocab`. The vocab is directly converted to a valid fairseq dict.

### Encoding with trained tokenizer

With the trained tokenizer I then encoded all datasets via `mmtl/scripts/infer_encode/multi_infer_encode.sh`

### Preparing for fairseq

Now we need to binarize the tokens in order be compatible with fairseq training. This is done
via classic fairseq preprocessing in `mmtl/scripts/prep/multi_fairseq-prep.sh`.
Note that here it is crucial to keep shared dictionaries. This is why we manually need to handle
seperate cases depending on the languages already processed.

## Training MMTL model

The MMTL model is trained in using fairaseq in `mmtl/scripts/train/train.sh`. Concerning hyperparameters I follow the
author's choices.
The introduction of the `LanguageSpecificEncoderLayer` to the fairseq code is only briefly explained in the manuscript, so I provide my step by approach here.

First we define the class in `fairseq/modules/transformer_layer.py` by adding the code provided by the authors in Listing 1:

```python
class LanguageSpecificEncoderLayer(nn.Module):
    def __init__(self, args, layer=0):
        super().__init__()
        self.index_language = args.language_specific_layers[layer]
        all_languages = sorted(set(self.get_lang(lp) for lp in args.lang_pairs))
        # self.models = nn.ModuleDict({lang: TransformerEncoderLayer(args, layer) for lang in all_languages})
        self.models = nn.ModuleDict({lang: TransformerEncoderLayer(args) for lang in all_languages})

    def get_lang(self, lang_pair):
        if self.index_language == "src":
            return lang_pair.split("-")[0]
        elif self.index_language == "tgt":
            return lang_pair.split("-")[1]
        else:
            raise ValueError(f"Invalid language {self.index_language}")
    
    def upgrade_state_dict_named(self, state_dict, name):
        """
        Rename layer norm states from `...layer_norms.0.weight` to
        `...self_attn_layer_norm.weight` and `...layer_norms.1.weight` to
        `...final_layer_norm.weight`
        """
        layer_norm_map = {"0": "self_attn_layer_norm", "1": "final_layer_norm"}
        for old, new in layer_norm_map.items():
            for m in ("weight", "bias"):
                k = "{}.layer_norms.{}.{}".format(name, old, m)
                if k in state_dict:
                    state_dict["{}.{}.{}".format(name, new, m)] = state_dict[k]
                    del state_dict[k]
    
    def forward(self, x, encoder_padding_mask, attn_mask: Optional[Tensor] = None):
        # self.lang_pair is set dynamically from outside the module.
        print(f"Using Language specific encoder for {self.index_language} lang {self.get_lang(self.lang_pair)} of pair {self.lang_pair}")
        return self.models[self.get_lang(self.lang_pair)].forward(x, encoder_padding_mask, attn_mask)
```

A few notes here: The method `upgrade_state_dict_named` is just a copy of the according method in `TransformerEncoderLayerBase` and is needed for the proper handling of the state dict downstream.
I do not see the necessity of the `layer` parameter to be passed to the `TransformerEncoderLayer` so
I omit it in my implementation.

Next, in order to allow the new layer to be built into the encoder block we modify `fairseq/models/transformer/transformer_encoder.py` to by adding the following method to `TransformerEncoderBase`

```python
    def build_language_specific_encoder_layer(self, cfg, layer):
        layer = transformer_layer.LanguageSpecificEncoderLayer(
            cfg, layer
        )
        checkpoint = cfg.checkpoint_activations
        if checkpoint:
            offload_to_cpu = cfg.offload_activations
            layer = checkpoint_wrapper(layer, offload_to_cpu=offload_to_cpu)
        # if we are checkpointing, enforce that FSDP always wraps the
        # checkpointed layer, regardless of layer size
        min_params_to_wrap = cfg.min_params_to_wrap if not checkpoint else 0
        layer = fsdp_wrap(layer, min_num_params=min_params_to_wrap)
        return layer
```

Note that here the layer parameter is indeed crucial in order to control downstream whether a src or tgt indexed
layer is desired.

Next, in the same module, we need to replace the concatenation of Transformer layers

```python    
    self.layers.extend(
        [self.build_encoder_layer(cfg) for i in range(cfg.encoder.layers)]
    )
```

with the LSLs at the desired positions
```python
    for i in range(cfg.encoder.layers):
        if i in [3, 4]:
            self.layers.append(self.build_language_specific_encoder_layer(cfg, i))
        elif i in [13, 14, 15]:
            self.layers.append(self.build_language_specific_encoder_layer(cfg, i))
        else:
            self.layers.append(self.build_encoder_layer(cfg))
            
    self.layers.extend(
        [self.build_encoder_layer(cfg) for i in range(cfg.encoder.layers)]
    )
```

Here I just hard coded the optimal configuration found by the author's in their architecture search, i.e.,
all layers except 3, 4, 13, 14, 15 are shared across languages.
Of course for future improvements this can be transferred to a more elegant approach.

Next, as also described by the authors, the optimal architecture comprises layers 3 and 4 to be srs indexed and
13, 14, 15 to be tgt indexed. Considering the implementation of `LanguageSpecificEncoderLayer` this is achieved 
in `args.language_specific_layers[layer]` by configuring the respective parameter.
This is done by adding to the transformer config under `fairseq/models/transformer/transformer_config.py`

```python
    language_specific_layers: Optional[List[str]] = field(
        default_factory=lambda: ['src'] * 8 + ['tgt'] * 8,
        metadata={
            "help": "A list of the form ['src', 'src', ..., 'tgt', 'tgt']",
        },
    )
```

Here I again hard coded the optimal configuration into the default argument, which exactly achieves that the first layers are src indexed and the second half of layers is tgt indexed.

Now the main point is that, even though we share all encoders and decoders across all language pairs, we need
to make language specific layers actually kick in correctly during training and inference. As noted by the authors this is achieved by dynamically providing the `lang_pair` attribute to the `LanguageSpecificEncoderLayer`
via 

```python
    LanguageSpecificEncoderLayer.lang_pair = property(lambda self: lang_pair)
```

The art consists now in finding the correct places in the massive fairseq codebase. However, conceptually it is clear that we need to perform this modification after the shared `MultilingualTransformer` model is instantiated both in training and inference.
The training is abstracted in the what fairseq denotes as tasks. Thus, in `fairseq/tasks/multilingual_translation.py` in the `train_step` we need to provide above dynamic definition in the
language specific loop

```python
    for idx, lang_pair in enumerate(curr_lang_pairs):
        LanguageSpecificEncoderLayer.lang_pair = property(lambda self: lang_pair)
```

The exact same modification needs also to be done in `valid_step`.

Finally, in order to arrive at the correct application of the trained model during generation we also need to modify the `_main` in `fairseq/fairseq_cli/generate.py`. The generation is performed for a single `lang_pair`
so naturally after this `lang_pair`is determined we introduce the dynamic attribute before the model is loaded.

```python
    lang_pair = cfg.task.source_lang + "-" + cfg.task.target_lang
    LanguageSpecificEncoderLayer.lang_pair = property(lambda self: lang_pair)
    models, saved_cfg = checkpoint_utils.load_model_ensemble(
        utils.split_paths(cfg.common_eval.path),
        arg_overrides=overrides,
        task=task,
        suffix=cfg.checkpoint.checkpoint_suffix,
        strict=(cfg.checkpoint.checkpoint_shard_count == 1),
        num_shards=cfg.checkpoint.checkpoint_shard_count,
    )
```

After applying these changes we are in the position to train and generate from the model.
The generation on the flores test set is done in `mmtl/scripts/generate/generate.sh`.
Note that even though the generation is done one lang pair and one direction at a time we need to provide
the lang pairs in order to indicate which pairs were used during training.

## Results

Due to compute limitations I only trained on the wmt21 dataset in order to test my implementation of the LSL.
Of course, due to its limited size wmt21 is not sufficient for training from scratch.
This is also seen from the genenerate output in `mmtl/results/en-de.txt`.

