#!usr/bin/bash

# $1 barcode file
index_dir_path="$2" #DON'T include long/short
input_path="$3"
output_path="$4"

# mkdir of sbatch scripts
mkdir -p $4"/sb_scripts"

# read the txt file and process it, skip the header
tail -n +2 $1 | awk -F'\t' '{print $2, $4}' | while read -r col2 col4
do
    sample_name="$col2"
    cmd_long_1="bowtie2 -x ${index_dir_path}/long -p 8 --end-to-end -k 2 -U ${input_path}/${sample_name}_${col4}.fq.gz -S ${sample_name}_${col4}.sam"
    cmd_long_2="bowtie2 -x ${index_dir_path}/long -p 8 --end-to-end -k 2 -1 ${input_path}/${sample_name}_${col4}_R1.fq.gz -1 ${input_path}/${sample_name}_${col4}_R2.fq.gz -S ${sample_name}_${col4}_notCombined.sam"
    cmd_short="bowtie2 -x ${index_dir_path}/short -p 8 --end-to-end -k 2 -U ${input_path}/${sample_name}_${col4}.fq.gz -S ${sample_name}_${col4}.sam"
    if [[ $sample_name == L* ]]
    then 
        command=${cmd_long_1}"; "${cmd_long_2}
    elif [[ $sample_name == S* ]]
    then
        command=${cmd_short}
    fi
    script="#!/bin/bash
#SBATCH -p RM
#SBATCH -t 30:00
#SBATCH -A bio200049p
#SBATCH -J bowtie2
#SBATCH -o bowtie_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH

$command
"

    script_name="bowtie_${sample_name}_${col4}.sh"
    echo "$script" > "$4/sb_scripts/$script_name"
done

echo "scripts generated!"
