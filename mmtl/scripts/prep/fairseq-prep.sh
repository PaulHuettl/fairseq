source .env

data="$BASE/data"
dataset=$1
src=$2
tgt=$3

dataset_enc="$data/enc/$dataset"

data_bin="$data/bin"
mkdir $data_bin

dataset_bin="$data_bin/$dataset"
mkdir $dataset_bin

if [ -f  "$dataset_bin/dict.$src.txt" ] && [ -f  "$dataset_bin/dict.$tgt.txt" ];
then
    echo "Both dicts exist"
    fairseq-preprocess \
        --trainpref "$dataset_enc/train.$src-$tgt.spm" \
        --validpref "$data/enc/flores-dev/validate.$src-$tgt.spm" \
        --testpref "$data/enc/flores-devtest/test.$src-$tgt.spm" \
        --destdir $dataset_bin \
        --srcdict "$dataset_bin/dict.$src.txt"\
        --tgtdict "$dataset_bin/dict.$tgt.txt"\
        --source-lang $src \
        --target-lang $tgt \
        --bpe sentencepiece \
        --workers 8 
else 
    if [ -f  "$dataset_bin/dict.$src.txt" ];
    then
        echo "Src dicts exist"
        fairseq-preprocess \
            --trainpref "$dataset_enc/train.$src-$tgt.spm" \
            --validpref "$data/enc/flores-dev/validate.$src-$tgt.spm" \
            --testpref "$data/enc/flores-devtest/test.$src-$tgt.spm" \
            --destdir $dataset_bin \
            --srcdict "$dataset_bin/dict.$src.txt"\
            --source-lang $src \
            --target-lang $tgt \
            --bpe sentencepiece \
            --workers 8 
    else
        if [ -f  "$dataset_bin/dict.$tgt.txt" ];
        then
            echo "Tgt dicts exist"
            fairseq-preprocess \
                --trainpref "$dataset_enc/train.$src-$tgt.spm" \
                --validpref "$data/enc/flores-dev/validate.$src-$tgt.spm" \
                --testpref "$data/enc/flores-devtest/test.$src-$tgt.spm" \
                --destdir $dataset_bin \
                --tgtdict "$dataset_bin/dict.$tgt.txt"\
                --source-lang $src \
                --target-lang $tgt \
                --bpe sentencepiece \
                --workers 8 
        fi
        if [ ! -f  "$dataset_bin/dict.$src.txt" ] && [ ! -f  "$dataset_bin/dict.$tgt.txt" ];
        then
            echo "No dicts exist, computing them anew"
            fairseq-preprocess \
                --trainpref "$dataset_enc/train.$src-$tgt.spm" \
                --validpref "$data/enc/flores-dev/validate.$src-$tgt.spm" \
                --testpref "$data/enc/flores-devtest/test.$src-$tgt.spm" \
                --destdir $dataset_bin \
                --source-lang $src \
                --target-lang $tgt \
                --bpe sentencepiece \
                --workers 8 
        fi
    fi
fi

