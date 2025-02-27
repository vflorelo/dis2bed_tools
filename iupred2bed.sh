#!/bin/bash
tsv_file=$1
prot_id=$2
grep -v "#" "${tsv_file}" | awk -v prot_id="${prot_id}" 'BEGIN{FS="\t";OFS="\t"}{if($3>=0.5){print prot_id,$1-1,$1,$2,$3,"+"}}'