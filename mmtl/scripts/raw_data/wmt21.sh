#! /usr/bin/bash

# used languages
# German
# English
# French 
# Japanese
# Chinese

source .env

data=$BASE/data/raw
mkdir $BASE/data
mkdir $data

declare -a pairs=('de-fr' 'fr-de'
                'en-de' 'de-en'
                'en-ja' 'ja-en'
                'zh-en' 'en-zh')

for i in "${pairs[@]}"
do 
    echo "Dowonloading language pair $i"
    src_lang=$(echo $i | cut -d'-' -f1)
    ref_lang=$(echo $i | cut -d'-' -f2)
    echo "SRC language is $src_lang"
    echo "REF language is $ref_lang"
    sacrebleu -t wmt21 -l $i --echo src > "$data/wmt21.$i.$src_lang"
    sacrebleu -t wmt21 -l $i --echo ref > "$data/wmt21.$i.$ref_lang"
    echo "Done with pair $i"
done
