#!usr/bin/bash
# @yzheng9 This script is to read in a TXT file, iterate line, and write into a sbtach script

# $1 barcode file
# $2 fastq dir full path
# $3 output path

three_end_barcode="AGATCTGTGATTAAGCCC"

# mkdir of sbatch scripts
mkdir -p $3"/sb_scripts"

previous_sample_name=""

# read the txt file and process it, skip the header
tail -n +2 $1 | awk -F'\t' '{print $2, $3, $7}' | while read -r col2 col3 col7
do
    sample_name="$col2"
    cmd1="cutadapt -j 4 -e 0 --trimmed-only -O 26 -a $three_end_barcode -g $col7 -o $3/${sample_name}_${col3}.fq $2/${sample_name}.extendedFrags.fastq"
    cmd2="cutadapt -j 4 -e 0 --trimmed-only -O 26 -a $three_end_barcode -g $col7 -o $3/${sample_name}_${col3}_R1.fq -p $3/${sample_name}_${col3}_R2.fq $2/${sample_name}.notCombined_1.fastq $2/${sample_name}.notCombined_2.fastq"
    script="#!/bin/bash
#SBATCH -p RM-shared
#SBATCH --ntasks-per-node=4
#SBATCH -t 15:00:00
#SBATCH -A bio200049p
#SBATCH -J cutadapt
#SBATCH -o cutadapt_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH
"
    command="
$cmd1
pigz -p 4 $3/${sample_name}_${col3}.fq
$cmd2
pigz -p 4 $3/${sample_name}_${col3}_R1.fq $3/${sample_name}_${col3}_R2.fq
"


    if [ "$sample_name" != "$previous_sample_name" ]
    then
        script_name="cutadapt_${sample_name}.sh" # _${col3}.sh
        echo "$script" > "$3/sb_scripts/$script_name"
        echo "$command" >> "$3/sb_scripts/$script_name"
    else
        echo "$command" >> "$3/sb_scripts/$script_name"
    fi
    previous_sample_name="$sample_name"

done

echo "scripts generated!"