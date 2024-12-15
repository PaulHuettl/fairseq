#! /usr/bin/bash

# used languages
# German (DE)
# English (EN)
# French (FR)
# Japanese (JA)
# Chinese (ZH)

# unavailable in wmt21
# Korean (KO)
# Portuguese (PT)
# Swahili (SW)
# Italian (IT)
# Spanish (ES)
mkdir data

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
    sacrebleu -t wmt21 -l $i --echo src > "data/wmt21.$i.$src_lang"
    sacrebleu -t wmt21 -l $i --echo ref > "data/wmt21.$i.$ref_lang"
    echo "Done with pair $i"
done
