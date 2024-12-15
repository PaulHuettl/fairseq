source .env

script="$BASE/scripts/prep/fairseq-prep.sh"
declare -a pairs=('de-fr' 'fr-de'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')
# declare -a pairs=('de-fr' 'fr-de'
#                 'en-de' 'de-en'
#                 'en-ja' 'ja-en'
#                 'zh-en' 'en-zh')

for i in "${pairs[@]}"
do
    echo "Preprocessing for $i"
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    bash $script 'wmt21' $src $tgt
done

declare -a lang=('de' 'fr' 'en' 'zh' 'ja')
for i in "${lang[@]}"
do
    cat $BASE/data/bin/wmt21/dict.*.txt > $BASE/data/bin/wmt21/dict_${i}_tmp.txt
done
for i in "${lang[@]}"
do
    mv $BASE/data/bin/wmt21/dict_${i}_tmp.txt $BASE/data/bin/wmt21/dict.${i}.txt
    sort -u $BASE/data/bin/wmt21/dict.${i}.txt > $BASE/data/bin/wmt21/dict.${i}.txt
done
