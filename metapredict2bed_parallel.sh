#!/bin/bash
csv_file=$1
fasta_file=$2
cutoff=$3
threads=$4
basename=$(echo "${fasta_file}" | rev | cut -d\. -f1 --complement | rev)
prot_list=$(grep \> ${fasta_file} | cut -d\> -f2 | cut -d' ' -f1 | sort -V | uniq)
echo "${prot_list}" | awk -v csv_file="${csv_file}" -v fasta_file="${fasta_file}" '{print "metapredict2bed.sh",$1,csv_file,fasta_file}' | parallel -j ${threads} > ${basename}.metapredict.bed
dis_from_bed.sh ${basename}.metapredict.bed ${cutoff} > ${basename}.metapredict.disordered.bed
