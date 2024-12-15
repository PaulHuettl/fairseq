data="/home/phuettl/DL/MTL/data"
data_bin="$data/bin"
mkdir $data_bin 


fairseq-preprocess \
    --trainpref "$data/enc/wmt21-en_de/train.en-de.spm" \
    --validpref "$data/enc/wmt21-en_de/train.en-de.spm" \
    --testpref "$data/enc/flores/dev/test.eng_Latn.spm" \
    --destdir $data_bin \
    --joined-dictionary \
    --srcdict "$data/enc/wmt21-en_de/dict.txt"\
    --source-lang "en" \
    --target-lang "de" \
    --bpe sentencepiece \
    --workers 8