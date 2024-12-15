SPM="$HOME/DL/sentencepiece/build/src"

model_dir='/home/phuettl/DL/MTL/scripts/encode'
model="$model_dir/flores.model"
vocab="$model_dir/flores.vocab"

data="$HOME/DL/MTL/data"
flores="$data/raw/flores200_dataset"

target_dir=$data/enc/flores

mkdir $target_dir

# create dictionary from trained vocab for fairseq
cut -f1 $vocab | tail -n +5 | sed "s/$/ 100/g" > $target_dir/dict.txt

# encode all language pairs
declare -a lang=('ces_Latn' 'deu_Latn'
                    'eng_Latn' 'fra_Latn'
                    'ita_Latn' 'jpn_Jpan'
                    'spa_Latn' 'zho_Hant')

mkdir $target_dir/dev
mkdir $target_dir/devtest

for i in "${lang[@]}"
do 
    echo "Encoding language $i"
    $SPM/spm_encode \
    --model=$model \
    --output_format=piece < \
    $flores/dev/$i.dev > \
    $target_dir/dev/test.$i.spm
    $SPM/spm_encode \
    --model=$model \
    --output_format=piece < \
    $flores/devtest/$i.devtest > \
    $target_dir/devtest/test.$i.spm
done


