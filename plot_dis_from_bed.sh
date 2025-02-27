#!/bin/bash
bed_fof=$1
sizes_file=$2
prot_id=$3
bed_file_list=$(cat ${bed_fof})
bed_file_count=$(echo "${bed_file_list}" | grep -v ^$ | wc -l)
prot_size=$(grep -w ^${prot_id} ${sizes_file} | cut -f2)
text_style="font-weight:bold;font-size:30pt;line-height:1;font-family:Spline Sans Mono;fill:#000000;fill-opacity:1;stroke:none"
legend_h_pad=$(echo -e "${prot_id}\n$(perl -pe 's/\.bed//' ${bed_fof})" | awk '{print length($0)*24}' | sort -n | tail -n1)
legend_h_pad=$(echo "${legend_h_pad}" | awk '{print $1+20+(10-($1%10))}')
v_size=$(echo -e "${prot_id}\n$(cat ${bed_fof})" | wc -l | awk '{print ($1*60)-30}')
h_size=$(echo -e "${prot_size}\t${legend_h_pad}" | awk '{print $1+$2}')
path_colours=$(echo -e "ffc000\nc0ff00\n00ffc0\n00c0ff\nc000ff\nff00c0")
svg_str="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
svg_str=$(echo -e "${svg_str}\n<svg width=\"${h_size}\" height=\"${v_size}\" viewBox=\"0 0 ${h_size} ${v_size}\">")
svg_str=$(echo -e "${svg_str}\n  <text style=\"${text_style}\" x=\"0\" y=\"30\"  id=\"prot_id\">${prot_id}</text>")
path_colour="404040"
path_style="fill:none;stroke:#${path_colour};stroke-width:20px;stroke-linecap:butt;stroke-linejoin:miter;stroke-dasharray:none;stroke-opacity:1"
svg_str=$(echo "${svg_str}\n  <path style=\"${path_style}\" d=\"M ${legend_h_pad} 10  H ${h_size}\" id=\"prot_bar\" />")
counter=0
for bed_file in ${bed_file_list}
do
    source_name=$(echo ${bed_file})
    counter=$(echo ${counter} | awk '{print $1+1}')
    vert_pos=$(echo "${counter}" | awk '{print ($1*60)+30}')
    counter_line=$(echo ${counter} | awk '{modulo=$1%6}{if(modulo==0){print 6}else{print modulo}}')
    path_colour=$(echo "${path_colours}" | tail -n+${counter_line} | head -n1 )
    path_style="fill:none;stroke:#${path_colour};stroke-width:20px;stroke-linecap:butt;stroke-linejoin:miter;stroke-dasharray:none;stroke-opacity:1"
    bed_datablock=$(grep -w ^${prot_id} ${bed_file} | grep -v ^$)
    dis_count=$(echo "${bed_datablock}" | grep -v ^$ | wc -l)
    bed_svg_str="  <text style=\"${text_style}\" x=\"0\" y=\"${vert_pos}\"  id=\"${source_name}\">${source_name}</text>"
    for dis_num in $(seq 1 ${dis_count})
    do
        dis_info=$(echo "${bed_datablock}" | tail -n+${dis_num} | head -n1 )
        start_pos=$(echo "${dis_info}" | awk -v pad="${legend_h_pad}" '{print $2+1+pad}')
        end_pos=$(echo   "${dis_info}" | awk -v pad="${legend_h_pad}" '{print $3+pad}')
        vert_pos=$(echo "${counter}" | awk '{print ($1*60)+10}')
        dis_svg_str="  <path style=\"${path_style}\" d=\"M ${start_pos} ${vert_pos}  H ${end_pos}\"  id=\"${source_name}_${counter}\" />"
        bed_svg_str=$(echo -e "${bed_svg_str}\n${dis_svg_str}")
    done
    svg_str=$(echo -e "${svg_str}\n${bed_svg_str}")
done
svg_str=$(echo -e "${svg_str}\n</svg>")
echo "${svg_str}" > ${prot_id}.svg