data=/home/phuettl/DL/MTL/data/bin
checkpoint=/home/phuettl/DL/MTL/data/checkpoint
mkdir $checkpoint

CUDA_VISIBLE_DEVICES=2 fairseq-train $data/wmt21 $data/tatoeba \
    --arch multilingual_transformer \
    --task multilingual_translation \
    --lang-pairs "de-fr,fr-de,en-de,de-en,en-ja,ja-en,zh-en,en-zh" \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --lr 4e-4 \
    --warmup-init-lr 1e-7 \
    --stop-min-lr 1e-9 \
    --lr-scheduler inverse_sqrt \
    --warmup-updates 4000 \
    --optimizer adam \
    --adam-betas '(0.9, 0.98)' \
    --max-tokens 4096 \
    --dropout 0.2 \
    --encoder-layers 16 \
    --encoder-embed-dim 512 \
    --decoder-layers 3 \
    --share-encoders \
    --share-decoders \
    --decoder-embed-dim 512 \
    --max-update 150000 \
    --max-epoch 100 \
    --distributed-world-size 1 \
    --distributed-port 54186 \
    --fp16 \
    --max-source-positions 10000 \
    --max-target-positions 10000 \
    --save-dir $checkpoint \
    --seed 1 \
    --save-interval 1