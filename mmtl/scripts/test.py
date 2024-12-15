from fairseq.models.multilingual_transformer import MultilingualTransformerModel

model = MultilingualTransformerModel.from_pretrained(
  '/home/phuettl/DL/MTL/data/checkpoint',
  checkpoint_file='checkpoint_best.pt',
  data_name_or_path='/home/phuettl/DL/MTL/data/bin',
  source_lang = 'en',
  target_lang = 'de'
)

model.translate('Hello world', beam=5)