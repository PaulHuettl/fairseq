source .env

script="$BASE/scripts/prep/fairseq-prep.sh"
declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')

for i in "${pairs[@]}"
do
    echo "Preprocessing for $i"
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    bash $script 'wmt21' $src $tgt
done