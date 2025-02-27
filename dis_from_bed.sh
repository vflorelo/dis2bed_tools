#!/bin/bash
bed_file=$1
cutoff=$2
mergeBed -i ${bed_file} -c 4,5,6 -o collapse,mean,mode | perl -pe 's/\,//g' | awk -v cutoff="${cutoff}" 'BEGIN{FS="\t"}{dis_len=$3-$2}{if(dis_len>=cutoff){print $0}}'