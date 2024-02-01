#!/bin/bash
bed_file=$1
fasta_file=$2
len_datablock=$(perl -pe 'if(/\>/){s/$/\t/};s/\n//g;s/\>/\n/g' ${fasta_file} | tail -n+2 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,length($2)}' | sort -V | uniq)
prot_list=$(cut -f1 ${bed_file} | sort -V | uniq )
for prot in ${prot_list}
do
    dis_datablock=$(grep -w ^${prot} ${bed_file})
    prot_len=$(echo "${len_datablock}" | grep -w ^${prot} | cut -f2)
    dis_len=$(echo  "${dis_datablock}" | awk 'BEGIN{FS="\t"}{dis_len+=($3-$2)}END{print dis_len}')
    dis_frac=$(echo -e "${prot_len}\t${dis_len}" | awk '{print $2/$1}')
    dis_count=$(echo "${dis_datablock}" | wc -l)
    nter_pos=$(echo ${prot_len} | awk '{print int($1/4)}' )
    cter_pos=$(echo ${prot_len} | awk '{print int($1-($1/4))}' )
    nter_bed=$(echo -e "${prot}\t0\t${nter_pos}\t${prot}_N_ter" )
    cter_bed=$(echo -e "${prot}\t${cter_pos}\t${prot_len}\t${prot}_C_ter")
    nter_frac=$(intersectBed -a <(echo "${nter_bed}") -b <(echo "${dis_datablock}") -wb | awk -v cdis_len="${dis_len}" 'BEGIN{FS="\t"}{dis_len+=$3-$2}END{print dis_len/cdis_len}')
    cter_frac=$(intersectBed -a <(echo "${cter_bed}") -b <(echo "${dis_datablock}") -wb | awk -v cdis_len="${dis_len}" 'BEGIN{FS="\t"}{dis_len+=$3-$2}END{print dis_len/cdis_len}')
    echo -e "${prot}\t${prot_len}\t${dis_count}\t${dis_len}\t${dis_frac}\t${nter_frac}\t${cter_frac}"
done