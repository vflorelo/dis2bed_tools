#!/bin/bash
prot_id=$1
csv_file=$2
fasta_file=$3
dis_block=$(grep -w ^${prot_id} ${csv_file} | cut -d\, -f1 --complement | perl -pe 's/\ //g;s/\,/\n/g' | awk 'BEGIN{OFS="\t"}{print NR-1,NR,$1}')
seq_block=$(seqtk subseq ${fasta_file} <(echo ${prot_id}) | grep -v \> | perl -pe 's/\n//g;s/(.{1,1})/$1\n/gs' | awk '{print NR"\t"$1}')
paste <(echo "${dis_block}") <(echo "${seq_block}") | awk -v prot_id="${prot_id}" 'BEGIN{FS="\t";OFS="\t"}{if(($2==$4)&&($3>=0.5)){print prot_id,$1,$2,$5,$3,"+"}}'