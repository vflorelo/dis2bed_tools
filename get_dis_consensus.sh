#!/bin/bash
bed_fof=$1
base_name=$2
cutoff=$3
bed_num=$(cat ${bed_fof} | sort -V | uniq | grep -v ^$ | wc -l)
min_cons=$(echo "${bed_num}" | awk '{print int($1)+1}')
bed_list=$(cat ${bed_fof} | sort -V | uniq | grep -v ^$)
multiIntersectBed -i $(echo ${bed_list}) > ${base_name}.consensus.tmp.bed
for i in $(seq ${min_cons} ${bed_num})
do
    awk -v i="${i}" 'BEGIN{FS="\t";OFS="\t"}{if($4>=i){print $1,$2,$3,$5}}' ${base_name}.consensus.tmp.bed > ${base_name}.cons_${i}.tmp.bed
    mergeBed -c 4 -o collapse -delim "|" -i ${base_name}.cons_${i}.tmp.bed | awk -v cutoff="${cutoff}" 'BEGIN{FS="\t"}{if(($3-$2)>=cutoff){print $0}}' > ${base_name}.cons_${i}.bed
done