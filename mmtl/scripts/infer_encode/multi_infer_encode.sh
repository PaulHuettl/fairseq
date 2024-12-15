source .env

script="$BASE/scripts/infer_encode/infer_encode.sh"
declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')

for i in "${pairs[@]}"
do
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    for dataset in 'wmt21' 'tatoeba'
    do
        echo "Inferring sentencepiece encoding for $i in $dataset"
        bash $script 'train' $dataset $src $tgt
    done

    echo "Inferring sentencepiece encoding for $i in flores-dev"
    bash $script 'validate' 'flores-dev' $src $tgt

    echo "Inferring sentencepiece encoding for $i in flores-devtest"
    bash $script 'test' 'flores-devtest' $src $tgt

done