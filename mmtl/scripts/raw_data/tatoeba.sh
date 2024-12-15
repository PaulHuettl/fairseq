source .env

data="$BASE/data"
tatoeba_raw="$data/raw/tatoeba"

mkdir $tatoeba_raw

declare -a pairs=('deu-fra' 'eng-jpn'
                'deu-eng' 'eng-zho')

for i in "${pairs[@]}"
do
    wget -O $tatoeba_raw/$i.tar https://object.pouta.csc.fi/Tatoeba-Challenge-v2023-09-26/$i.tar
done
for i in "${pairs[@]}"
do
    tar -xvf $tatoeba_raw/$i.tar
done
for i in "${pairs[@]}"
do
    gzip -d $data/release/v2023-09-26/$i/train.src.gz
    gzip -d $data/release/v2023-09-26/$i/train.trg.gz
done
for i in "${pairs[@]}"
do
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    mv $data/release/v2023-09-26/$i/train.src $tatoeba_raw/tatoeba.$i.$src
    mv $data/release/v2023-09-26/$i/train.trg $tatoeba_raw/tatoeba.$i.$tgt
    cp $tatoeba_raw/tatoeba.$i.$src $tatoeba_raw/tatoeba.$tgt-$src.$src
    cp $tatoeba_raw/tatoeba.$i.$tgt $tatoeba_raw/tatoeba.$tgt-$src.$tgt
done

declare -a pairs=('deu-fra-de-fr' 'fra-deu-fr-de' 
                    'eng-jpn-en-ja' 'jpn-eng-ja-en'
                    'deu-eng-de-en' 'eng-deu-en-de'
                    'eng-zho-en-zh' 'zho-eng-zh-en')
                    
for i in "${pairs[@]}"
do
    src=$(echo $i | cut -d'-' -f1)
    tgt=$(echo $i | cut -d'-' -f2)
    src_re=$(echo $i | cut -d'-' -f3)
    tgt_re=$(echo $i | cut -d'-' -f4)
    mv $tatoeba_raw/tatoeba.$src-$tgt.$src $tatoeba_raw/tatoeba.$src_re-$tgt_re.$src_re
    mv $tatoeba_raw/tatoeba.$tgt-$src.$src $tatoeba_raw/tatoeba.$tgt_re-$src_re.$src_re
    mv $tatoeba_raw/tatoeba.$src-$tgt.$tgt $tatoeba_raw/tatoeba.$src_re-$tgt_re.$tgt_re
    mv $tatoeba_raw/tatoeba.$tgt-$scr.$tgt $tatoeba_raw/tatoeba.$tgt_re-$src_re.$tgt_re
done


