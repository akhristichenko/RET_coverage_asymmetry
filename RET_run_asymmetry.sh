#!/bin/bash
 
while getopts ":S:G:O:" flag;
do
	case $flag in
		S) sample_path=$OPTARG ;;
    G) gene_name=$OPTARG  ;;
		O) output_dir=$OPTARG ;;
	esac
										         
done

tmp=$output_dir/tmp/
mkdir -p $output_dir
mkdir -p $output_dir/tmp/

filename=$(basename "$sample_path")
sample_name="${filename%Aligned.sortedByCoord.out.bam}"
echo "$sample_name"

gene_coordianate=$(./get_genes_coordiantes.sh "$gene_name")
echo $gene_coordianate


samtools view -b $sample_path "$gene_coordianate" > $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam
if samtools view -H $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam | grep '@RG'
then
   pass;
else
    samtools addreplacerg -r "@RG\tID:RG1\tSM:SampleName\tPL:Illumina\tLB:Library.fa" -o $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.2.bam $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam;
fi
mv $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.2.bam $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam

#samtools view $tmp/$sample_name""Aligned.sortedByCoord.out.gene.bam | wc -l
picard MarkDuplicates REMOVE_DUPLICATES=true I=$tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam O=$tmp/$sample_name""Aligned.sortedByCoord.out.bam M=$output_dir/metrices.txt VERBOSITY=ERROR QUIET=true
samtools index $tmp/$sample_name""Aligned.sortedByCoord.out.bam

python3 $(dirname "$0")/RET_TKR_script_sense_asymmetry.paper.py  -i $tmp/$sample_name""Aligned.sortedByCoord.out.bam -o $output_dir/ --genes $gene_name --stats $output_dir/coverage_stats.SnS.csv  --plot_all --table $output_dir/exons_stats.paper.csv --original $sample_path

rm $tmp/$sample_name""Aligned.sortedByCoord.out.bam* $tmp/$sample_name""Aligned.sortedByCoord.out.$gene_name.bam


