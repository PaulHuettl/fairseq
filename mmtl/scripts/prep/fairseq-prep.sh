data="$BASE/data"
model_name=$1
dataset=$2
src=$3
tgt=$4

dataset_enc="$data/enc/$dataset"

data_bin="$data/bin"
mkdir $data_bin

dataset_bin="$data_bin/$dataset"
mkdir $dataset_bin

if [ -f  "$dataset_bin/dict.$src.txt" ] && [ -f  "$dataset_bin/dict.$tgt.txt" ];
then
    echo "Both dicts exist"
    fairseq-preprocess \
        --trainpref "$dataset_enc/$dataset.$src-$tgt.spm" \
        --validpref "$data/enc/flores_dev/flores-dev.$src-$tgt.spm" \
        --testpref "$data/enc/flores_devtest/flores-devtest.$src-$tgt.spm" \
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
            --trainpref "$dataset_enc/$dataset.$src-$tgt.spm" \
            --validpref "$data/enc/flores_dev/flores-dev.$src-$tgt.spm" \
            --testpref "$data/enc/flores_devtest/flores-devtest.$src-$tgt.spm" \
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
                --trainpref "$dataset_enc/$dataset.$src-$tgt.spm" \
                --validpref "$data/enc/flores_dev/flores-dev.$src-$tgt.spm" \
                --testpref "$data/enc/flores_devtest/flores-devtest.$src-$tgt.spm" \
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
                --trainpref "$dataset_enc/$dataset.$src-$tgt.spm" \
                --validpref "$data/enc/flores_dev/flores-dev.$src-$tgt.spm" \
                --testpref "$data/enc/flores_devtest/flores-devtest.$src-$tgt.spm" \
                --destdir $dataset_bin \
                --source-lang $src \
                --target-lang $tgt \
                --bpe sentencepiece \
                --workers 8 
        fi
    fi
fi

