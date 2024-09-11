#!/bin/bash
base_name=$1
bed_fof=$2
min_len=$3
min_count=$4
bed_list=$(cat ${bed_fof} | sort -V | uniq | grep -v ^$)
multiIntersectBed -i $(echo ${bed_list}) > ${base_name}.consensus.tmp.bed
awk -v min_count="${min_count}" 'BEGIN{FS="\t";OFS="\t"}{if($4>=min_count){print $1,$2,$3,$5}}' ${base_name}.consensus.tmp.bed > ${base_name}.consensus.${min_count}.tmp.bed
mergeBed -c 4 -o collapse -delim "|" -i ${base_name}.consensus.${min_count}.tmp.bed | awk -v min_len="${min_len}" 'BEGIN{FS="\t"}{if(($3-$2)>=min_len){print $0}}' > ${base_name}.consensus.${min_count}.bed
rm ${base_name}.consensus.tmp.bed ${base_name}.consensus.${min_count}.tmp.bed