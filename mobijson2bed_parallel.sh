#!/bin/bash
json_file=$1
threads=$2
basename=$(echo "${json_file}" | rev | cut -d\. -f1 --complement | rev)
pred_list=$(grep -n "prediction-disorder-mobidb_lite" ${json_file} | cut -d\: -f1 | grep -v ^$)
pred_count=$(echo "${pred_list}" | grep -v ^$ | wc -l )
if [ "${pred_count}" -gt 0 ]
then
    echo "${pred_list}" | awk -v json_file="${json_file}" '{print "mobijson2bed.py <(sed -n \""  $1 ","$1"p\"",json_file,")"}' | parallel -j ${threads} > ${basename}.bed
fi
dis_from_bed.sh ${basename}.bed 10 > ${basename}.disordered.bed
