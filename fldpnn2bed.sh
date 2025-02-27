#!/bin/bash
csv_file=$1
basename=$2
if [ -f "${basename}.fldpnn.bed" ]
then
  rm "${basename}.fldpnn.bed"
fi
line_ranges=$(paste <(grep -n \> ${csv_file} | cut -d\: -f1) <(cat <(grep -n \> ${csv_file} | cut -d\: -f1 | tail -n+2 | awk '{print $1-1}') <(cat ${csv_file} | wc -l)))
range_count=$(echo "${line_ranges}" | grep -v ^$ | wc -l )
if [ "${range_count}" -gt 0 ]
then
    for i in $(seq 1 ${range_count})
    do
        range=$(echo "${line_ranges}" | tail -n+${i} | head -n1 | perl -pe 's/\t/\,/;s/$/p/')
        datablock=$(sed -n "${range}" ${csv_file} | grep -v "Residue Type")
        seq_id=$(echo  "${datablock}" | grep    \> | cut -d\> -f2)
        bed_str=$(echo "${datablock}" | grep -v \> | awk 'BEGIN{FS=",";OFS="\t"}{if($4!=0){print $1-1,$1,$2,$3,"+"}}')
        bed_count=$(echo "${bed_str}" | grep -v ^$ | wc -l)
        if [ "${bed_count}" -gt 0 ]
        then
            echo "${bed_str}" | perl -pe "s/^/${seq_id}\t/" >> ${basename}.fldpnn.bed
        fi
    done
fi
if [ -s "${basename}.fldpnn.bed" ]
then
  dis_from_bed.sh ${basename}.fldpnn.bed 10 > ${basename}.fldpnn.disordered.bed
fi
