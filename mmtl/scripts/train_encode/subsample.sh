base='/home/phuettl/DL/MTL'
export PATH="$PATH:/home/phuettl/DL/subsample"

output_dir="$base/data/subsample"
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
    subsample -n 1500000 $base/data/raw/tatoeba/tatoeba.$i.$src > $output_dir/tatoeba_sub.$i.$src
    subsample -n 1500000 $base/data/raw/tatoeba/tatoeba.$i.$tgt > $output_dir/tatoeba_sub.$i.$tgt
    cp $base/data/raw/wmt21/wmt21.$i.$src $output_dir/wmt21_sub.$i.$src
    cp $base/data/raw/wmt21/wmt21.$i.$tgt $output_dir/wmt21_sub.$i.$tgt
done



