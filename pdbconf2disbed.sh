#!/bin/bash
pdb_file=$1
bed_file=$2
min_len=$3
min_conf=$4
acc_no=$(echo "${pdb_file}" | sed 's/\.pdb//')
low_conf_data=$(grep -w ^ATOM ${pdb_file} | cut -c23-26,61-66 | sed 's/./&\t/4;s/ //g' | sort -nk1 | uniq | awk -v min_conf="${min_conf}" 'BEGIN{FS="\t"}{if($2<min_conf){print $0}}')
echo "${low_conf_data}"
low_conf_count=$(echo "${low_conf_data}" | grep -v ^$ | grep -c .)
if [ "${low_conf_count}" -eq 0 ]
then
    echo "No disordered regions found"
    exit 0
else
    low_conf_bed=$(echo "${low_conf_data}" | awk -v acc_no="${acc_no}" 'BEGIN{FS="\t";OFS="\t"}{print acc_no,$1-1,$1,"disordered",$2}')
fi
echo "${low_conf_bed}"
merge_data=$(mergeBed -o mode,mean -c 4,5 -i <(echo "${low_conf_bed}") | awk -v min_len="${min_len}" 'BEGIN{FS="\t";OFS="\t";len=$3-$2}{if(len>=min_len){print $1,$2,$3,$4,$5}}')
merge_data_count=$(echo "${merge_data}" | grep -v ^$ | grep -c .)
if [ "${merge_data_count}" -eq 0 ]
then
    echo "No disordered regions found"
    exit 0
else
    echo "${merge_data}" > ${bed_file}
fi