source .env

data=$BASE/data/bin

src='en'
tgt='de'
lang_pairs='de-fr,fr-de,en-de,de-en,en-ja,ja-en,zh-en,en-zh'

fairseq-generate $data/wmt21 \
  --path $CHECKPOINT/checkpoint_best.pt \
  --task multilingual_translation \
  --gen-subset test \
  --source-lang $src \
  --target-lang $tgt \
  --sacrebleu --remove-bpe 'sentencepiece'\
  --batch-size 32 \
  --lang-pairs "$lang_pairs" > ${src}_${tgt}.txt