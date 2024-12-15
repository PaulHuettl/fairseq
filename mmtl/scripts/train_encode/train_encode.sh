source .env

data="$BASE/data"
output_dir="$BASE/data/model_vocab"
declare -a datasets=('wmt21' 'tatoeba')
model_name="MMTL_spm"

declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')
input=""
for d in "${datasets[@]}"
do
    for i in "${pairs[@]}"
    do
        echo "Adding $i of $d to sentencepiece training"
        src=$(echo $i | cut -d'-' -f1)
        tgt=$(echo $i | cut -d'-' -f2)
        input+="$data/subsample/${d}_sub.$i.$src,$data/subsample/${d}_sub.$i.$tgt,"
    done
done

echo "Training Encoding ..."
$SPM/spm_train --input=$input \
    --vocab_size=250000 \
    --character_coverage=0.9995 \
    --model_prefix=$model_name \
    --model_type=unigram \
    --num_threads=50 \

mv $PWD/$model_name.model $output_dir
mv $PWD/$model_name.vocab $output_dir

cut -f1 $output_dir/$model_name.vocab | tail -n +5 | sed "s/$/ 100/g" > $output_dir/$model_name.dict.txt