#!/bin/bash
run_id=$(uuidgen | cut -d- -f5)
fasta_file=$1
basename=$(echo "${fasta_file}" | rev | cut -d\. -f1 --complement | rev)
threads=$2
len_block=$(perl -pe 'if(/\>/){s/$/\t/};s/\n//g;s/\>/\n/g' ${fasta_file} | tail -n+2 | awk 'BEGIN{FS="\t"}{print $1 FS length($2) FS $2}' | sort -nk2)
longest=$(echo "${len_block}" | tail -n1 | cut -f2)
if [ -f "fldpnn_commands.txt" ]
then
    rm fldpnn_commands.txt
fi

if [ -f "cat_commands.txt" ]
then
    rm cat_commands.txt
fi
if [ -f "rm_commands.txt" ]
then
    rm rm_commands.txt
fi
a=0
while [ ! -z "${len_block}" ]
do
    uuid=$(uuidgen | cut -d- -f5)
    prot_list=$(echo "${len_block}" | awk -v longest="${longest}"  'BEGIN{FS="\t"}{sum+=$2}{if(sum<=longest){print $1}}')
    mkdir -p ${uuid}
    seqtk subseq ${fasta_file} <(echo "${prot_list}") > ${uuid}/${uuid}.fasta
    len_block=$(echo "${len_block}" | grep -v "${prot_list}")
    echo "run_flDPnn.py ${uuid}/${uuid}.fasta" >> fldpnn_commands.txt
    echo "cat ${uuid}/results.csv" >> cat_commands.txt
    echo "rm -rf ${uuid}" >> rm_commands.txt
done
cat fldpnn_commands.txt | parallel -j ${threads} > parallel.fldpnn.${run_id}.log >> parallel.fldpnn.${run_id}.err
cat cat_commands.txt    | parallel -j ${threads} > ${basename}.fldpnn.csv        >> parallel.cat.${run_id}.err
#cat rm_commands.txt     | parallel -j ${threads} > parallel.rm.${run_id}.log     >> parallel.rm.${run_id}.err
#rm fldpnn_commands.txt cat_commands.txt rm_commands.txt
