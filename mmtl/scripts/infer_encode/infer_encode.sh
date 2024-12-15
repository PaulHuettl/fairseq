source .env

data="$BASE/data"
model_name='MMTL_spm'
mode=$1
dataset=$2
src=$3
tgt=$4

model="$data/model_vocab/$model_name.model"
vocab="$data/model_vocab/$model_name.vocab"

mkdir $data/enc
output_dir=$data/enc/$dataset
mkdir $output_dir

echo "Encoding ..."
for lang in $src $tgt
do
    $SPM/spm_encode \
        --model=$model \
        --output_format=piece < \
        $data/raw/$dataset/$dataset.$src-$tgt.$lang > \
        $output_dir/$mode.$src-$tgt.spm.$lang
done


