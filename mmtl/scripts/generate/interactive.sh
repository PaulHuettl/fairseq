data=/home/phuettl/DL/MTL/data/bin
checkpoint=/home/phuettl/DL/MTL/data/checkpoint

fairseq-interactive $data \
    --path $checkpoint/checkpoint_best.pt \
    --beam 5 --source-lang en  --target-lang de \
    --remove-bpe 'sentencepiece'