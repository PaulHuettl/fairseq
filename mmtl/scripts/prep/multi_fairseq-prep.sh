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
    bash $script 'tatoeba' $src $tgt
done

declare -a lang=('de' 'fr' 'en' 'zh' 'ja')
for i in "${lang[@]}"
do
    cat $BASE/data/bin/tatoeba/dict.*.txt > $BASE/data/bin/tatoeba/dict_${i}_tmp.txt
done
for i in "${lang[@]}"
do
    mv $BASE/data/bin/tatoeba/dict_${i}_tmp.txt $BASE/data/bin/tatoeba/dict.${i}.txt
    sort -u -k1,1 $BASE/data/bin/tatoeba/dict.${i}.txt > $BASE/data/bin/tatoeba/dict.${i}_sorted.txt
    mv $BASE/data/bin/tatoeba/dict.${i}_sorted.txt $BASE/data/bin/tatoeba/dict.${i}.txt
done
