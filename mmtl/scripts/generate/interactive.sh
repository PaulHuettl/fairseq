source .env

data=$BASE/data/bin

fairseq-interactive $data \
    --path $CHECKPOINT/checkpoint_best.pt \
    --beam 5 --source-lang en  --target-lang de \
    --remove-bpe 'sentencepiece'