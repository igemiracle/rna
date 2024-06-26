#!usr/bin/bash
# @yzheng9 This script is to read in a TXT file, iterate line, and write into a sbtach script

# $1 barcode file
# $2 fastq dir full path
# $3 output path

three_end_barcode="AGATCTGTGATTAAGCCC"

# mkdir of sbatch scripts
mkdir -p $3"/sb_scripts"


# read the txt file and process it, skip the header
tail -n +2 $1 | awk -F'\t' '{print $2, $4, $7}' | while read -r col2 col4 col7
do
    sample_name="$col2"
    cmd1="cutadapt -j 8 -e 0 --trimmed-only -O 26 -a $three_end_barcode -g $col7 -o $3/${sample_name}_${col4}.fq $2/${sample_name}.extendedFrags.fastq"
    cmd2="cutadapt -j 8 -e 0 --trimmed-only -O 26 -a $three_end_barcode -g $col7 -o $3/${sample_name}_${col4}_R1.fq -p $3/${sample_name}_${col4}_R2.fq $2/${sample_name}.notCombined_1.fastq $2/${sample_name}.notCombined_2.fastq"
    script="#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -t 40:00
#SBATCH -A bio200049p
#SBATCH -J cutadapt
#SBATCH -o cutadapt_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH

$cmd1
pigz -p 8 $3/${sample_name}_${col4}.fq
$cmd2
pigz -p 8 $3/${sample_name}_${col4}_R1.fq $3/${sample_name}_${col4}_R2.fq
"

    script_name="cutadapt_${sample_name}_${col4}.sh"
    echo "$script" > "$3/sb_scripts/$script_name"
done

echo "scripts generated!"