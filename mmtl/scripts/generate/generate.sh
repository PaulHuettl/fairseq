data=/home/phuettl/DL/MTL/data/bin
checkpoint=/home/phuettl/DL/MTL/data/checkpoint

src=en
tgt=de
lang_pairs="de-fr,fr-de,en-de,de-en,en-ja,ja-en,zh-en,en-zh"

fairseq-generate $data \
  --path $checkpoint/checkpoint_best.pt \
  --task multilingual_translation \
  --gen-subset test \
  --source-lang $src \
  --target-lang $tgt \
  --sacrebleu --remove-bpe 'sentencepiece'\
  --batch-size 32 \
  --lang-pairs "$lang_pairs" > ${src}_${tgt}.txt