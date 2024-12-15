#! /usr/bin/bash

# used languages
# German
# English
# French
# Japanese
# Chinese

source .env


mkdir $BASE/data
mkdir $BASE/data/raw

data="$BASE/data/raw/flores200_dataset"

declare -a lang=('deu_Latn'
                    'eng_Latn' 'fra_Latn'
                    'jpn_Jpan'
                    'zho_Hant')

output_dev="$BASE/data/raw/flores-dev"
output_devtest="$BASE/data/raw/flores-devtest"
mkdir $output_dev
mkdir $output_devtest

for i in "${lang[@]}"
do 
    mv $data/dev/$i.dev $output_dev
    mv $data/devtest/$i.devtest $output_devtest
done

# Now adapt data to common format
declare -a pairs=('deu_Latn-de'
                    'eng_Latn-en' 'fra_Latn-fr'
                    'jpn_Jpan-ja'
                    'zho_Hant-zh')
for i in "${pairs[@]}"
do
    lang=$(echo $i | cut -d'-' -f1)
    lang_re=$(echo $i | cut -d'-' -f2)
    mv $output_dev/$lang.dev $output_dev/flores-dev.$lang_re
    mv $output_devtest/$lang.devtest $output_devtest/flores-devtest.$lang_re
done

declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')
for p in "${pairs[@]}"
do
    src=$(echo $p | cut -d'-' -f1)
    tgt=$(echo $p | cut -d'-' -f2)    
    cp $output_dev/flores-dev.$src $output_dev/flores-dev.$p.$src
    cp $output_dev/flores-dev.$tgt $output_dev/flores-dev.$p.$tgt
    cp $output_devtest/flores-devtest.$src $output_devtest/flores-devtest.$p.$src
    cp $output_devtest/flores-devtest.$tgt $output_devtest/flores-devtest.$p.$tgt
done
