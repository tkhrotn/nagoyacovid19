#!/bin/bash

cd data/
rm *.pdf
wget -r -l 1 -A pdf -nd -nc https://www.pref.aichi.jp/site/covid19-aichi/kansensya-kensa.html
Rscript ../parseAichiSummary.R `ls *.pdf` aichi_summary.csv
mv `ls *.pdf` aichi/
cd ..

cd data/nagoya

wget -r -l 1 -A csv -nd -nc http://www.city.nagoya.jp/kenkofukushi/page/0000126920.html
wget -r -l 1 -A pdf -nd -nc http://www.city.nagoya.jp/kenkofukushi/page/0000126920.html

rm symptom.txt
touch symptom.txt

rm patient.txt
touch patient.txt

rm onset.txt
touch onset.txt

rm positive.txt
touch positive.txt

files=`ls *.pdf | grep -v sibo | grep -v R2072 | grep -v R20214kisya.pdf | grep -v R2073 | grep -v R208`

for i in ${files}; do
    echo ${i}
    pdftotext ${i} - | tr -d "\f" | grep 主な症状 | awk -F '：' '{print $2}' | nl -s " " | sed "s/^/${i} /g" >> symptom.txt
    pdftotext ${i} - | grep 歳 | grep -v 患者 | grep -v 年代 | nl -s " " | sed "s/^/${i} /g" >> patient.txt
    Rscript ../../parseOnsetDate.R "${i}" "発熱|微熱|咳|倦怠感|下痢|味覚|嗅覚|臭覚|肺炎|頭|鼻|咽頭|のど|背中|呼吸|痛|痰|脱力感|食欲" | tr -d "\f" | sed "s/～//g" | sed "s/東京都滞在。//g" | sed "s/に発熱。//g" | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> onset.txt
    Rscript ../../parseTestPositiveDate.R "${i}" | tr -d "\f" | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> positive.txt
done

echo "R20214kisya.pdf      1 発熱、呼吸器症状" >> symptom.txt
echo "R20214kisya.pdf      1 60 歳代 男性 市内在住" >> patient.txt
echo "R20214kisya.pdf      1 2,8,(土)" >> onset.txt
echo "R20214kisya.pdf      1 2,14,(金)" >> positive.txt

echo "R20308kanjyasibou.pdf    0  死亡" >> symptom.txt
echo "R20308kanjyasibou.pdf    0  80 歳代 男性 市内在住" >> patient.txt
echo "R20308kanjyasibou.pdf    0  3,7,(土)" >> onset.txt
echo "R20308kanjyasibou.pdf    0  3,7,(土)" >> positive.txt


# 2020/7/20-23

files=`ls *.pdf | grep R207 | grep -v R2070 | grep -v R2071 | grep -v R206 | grep -v R202 | grep -v R203 | grep -v R204 | grep -v R200 | grep -v sibou | grep -v R20724 | grep -v R20725 | grep -v R20726 | grep -v R20727 | grep -v R20728 | grep -v R20729 | grep -v R2073`

for i in ${files}; do
    echo ${i}
    Rscript ../../parseSymptom.R "${i}" | nl -s " " | sed "s/^/${i} /g" >> symptom.txt
    pdftotext -raw "${i}" - | grep 発症日 | awk -F ' ' '{print $2$3$4$5}' | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> onset.txt
    pdftotext -raw "${i}" - | grep 陽性確定日 | awk -F ' ' '{print $2$3$4$5}' | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> positive.txt
done

echo "R20722kanjyahappyouhp(sibou).pdf    0  死亡" >> symptom.txt
echo "R20722kanjyahappyouhp(sibou).pdf    0  80 歳代 男性 市内在住" >> patient.txt
echo "R20722kanjyahappyouhp(sibou).pdf    0  7,22,(水)" >> onset.txt
echo "R20722kanjyahappyouhp(sibou).pdf    0  7,22,(水)" >> positive.txt


# 2020/7/24-

files=`ls *.pdf | grep -E "R207|R208" | grep -v R2070 | grep -v R2071 | grep -v sibou | grep -v R20720 | grep -v R20721 | grep -v R20722 | grep -v R20723`

for i in ${files}; do
    echo ${i}
    Rscript ../../parseNagoyaCOVID19.R "${i}" | awk -F ' ' '{print $8}' | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> symptom.txt
    Rscript ../../parseNagoyaCOVID19.R "${i}" | awk -F ' ' '{print $6}' | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> onset.txt
    Rscript ../../parseNagoyaCOVID19.R "${i}" | awk -F ' ' '{print $7}' | sed "s/月/,/g" | sed "s/日/,/g" | nl -s " " | sed "s/^/${i} /g" >> positive.txt
done


cd ../..

Rscript makeNagoyaCOVID19Data.R