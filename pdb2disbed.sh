#!/bin/bash
pdb_file=$1
bed_file=$2
min_len=$3
acc_no=$(echo "${pdb_file}" | sed 's/\.pdb//')
dssp_data=$(mkdssp -i ${pdb_file} -o /dev/stdout)
start_line=$(echo   "${dssp_data}" | grep -n "#" | head -n1 | cut -d\: -f1 | awk '{print $1+1}')
dis_res_list=$(echo "${dssp_data}" | tail -n+${start_line} | cut -c1-5,17-25 | sed 's/./&\t/5' | sed 's/\t[a-z]/\@/i' | grep -v "@" | awk '{print $1}' )
dis_res_count=$(echo "${dis_res_list}" | grep -v ^$ | grep -c .)
if [ "${dis_res_count}" -lt "${min_len}" ]
then
    echo "Number of disordered residues is less than the specified minimum (${min_len})"
    exit 0
fi
dis_bed_data=$(echo "${dis_res_list}" | awk -v acc_no="${acc_no}" 'BEGIN{FS="\t";OFS="\t"}{print acc_no,$1-1,$1,"disordered"}')
dis_bed_data=$(echo "${dis_bed_data}" | mergeBed | awk -v min_len="${min_len}" 'BEGIN{FS="\t"}{if(($3-$2)>=min_len){print $0}}')
dis_bed_count=$(echo "${dis_bed_data}" | grep -v ^$ | grep -c .)
if [ "${dis_bed_count}" -eq 0 ]
then
    echo "No disordered regions found"
    exit 0
fi
conf_res_data=$(grep -w ^ATOM ${pdb_file} | cut -c23-26,61-66 | sed 's/./&\t/4;s/ //g' | sort -nk1 | uniq)
conf_bed_data=$(echo "${conf_res_data}" | awk -v acc_no="${acc_no}" 'BEGIN{FS="\t";OFS="\t"}{print acc_no,$1-1,$1,$2}')
intersect_data=$(intersectBed -wa -a <(echo "${conf_bed_data}") -b <(echo "${dis_bed_data}"))
merge_data=$(mergeBed -o mean -c 4 -i <(echo "${intersect_data}") | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,"disorder",$4}' )
merge_data_count=$(echo "${merge_data}" | grep -v ^$ | grep -c .)
if [ "${merge_data_count}" -eq 0 ]
then
    echo "No disordered regions found"
    exit 0
else
    echo "${merge_data}" > ${bed_file}
fi