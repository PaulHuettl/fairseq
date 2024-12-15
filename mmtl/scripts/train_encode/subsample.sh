source .env

export PATH="$PATH:$SUBSAMPLE"

output_dir="$BASE/data/subsample"
mkdir $output_dir

declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')

for i in "${pairs[@]}"
do
    echo "Subsampling $i from $d"
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    subsample -n 1500000 $BASE/data/raw/tatoeba/tatoeba.$i.$src > $output_dir/tatoeba_sub.$i.$src
    subsample -n 1500000 $BASE/data/raw/tatoeba/tatoeba.$i.$tgt > $output_dir/tatoeba_sub.$i.$tgt
    cp $BASE/data/raw/wmt21/wmt21.$i.$src $output_dir/wmt21_sub.$i.$src
    cp $BASE/data/raw/wmt21/wmt21.$i.$tgt $output_dir/wmt21_sub.$i.$tgt
done



