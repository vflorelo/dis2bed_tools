#!/bin/bash
fasta_file=$1
basename=$(echo "${fasta_file}" | rev | cut -d\. -f1 --complement | rev)
iupred_version=$2
cutoff=$3
threads=$4
if [ "${iupred_version}" == "2a" ]
then
    pgm="iupred2a.py"
    ver="2"
elif [ "${iupred_version}" == "3" ]
then
    pgm="iupred3.py"
    ver="3"
fi
prot_list=$(grep \> ${fasta_file} | cut -d\> -f2 | cut -d' ' -f1 | sort -V | uniq)
uuid_list=$(echo "${prot_list}" | awk '{print "uuidgen | cut -d- -f5"}' | parallel)
paste <(echo "${prot_list}") <(echo "${uuid_list}") | awk -v fasta_file="${fasta_file}" '{print "seqtk subseq " fasta_file" <(echo "$1") > "$2".fasta"}' | parallel -j $threads
echo "${uuid_list}" | awk -v pgm="${pgm}" -v ver="${ver}" '{print pgm,$1".fasta long > "$1".iupred"ver".out"}' | parallel -j $threads
paste <(echo "${uuid_list}") <(echo "${prot_list}") | awk -v ver="${ver}" '{print "iupred2bed.sh "$1".iupred"ver".out",$2}' | parallel -j $threads > ${basename}.iupred${ver}.bed
echo "${uuid_list}" | awk -v ver="${ver}" '{print "rm "$1".fasta",$1".iupred"ver".out"}' | parallel -j $threads
dis_from_bed.sh ${basename}.iupred${ver}.bed ${cutoff} > ${basename}.iupred${ver}.disordered.bed
