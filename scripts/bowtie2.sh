#!usr/bin/bash

# $1 barcode file
index_dir_path="$2" #DON'T include long/short
input_path="$3"
output_path="$4"

# mkdir of sbatch scripts
mkdir -p $4"/sb_scripts"

# read the txt file and process it, skip the header
tail -n +2 $1 | awk -F'\t' '{print $2, $3}' | while read -r col2 col3
do
    sample_name="$col2"
    cmd_long_1="bowtie2 -x ${index_dir_path}/long -p 4 --end-to-end -k 2 -U ${input_path}/${sample_name}_${col3}.fq.gz | samtools view -@ 4 -bS > ${sample_name}_${col3}.bam"
    cmd_long_2="bowtie2 -x ${index_dir_path}/long -p 4 --end-to-end -k 2 -1 ${input_path}/${sample_name}_${col3}_R1.fq.gz -2 ${input_path}/${sample_name}_${col3}_R2.fq.gz | samtools view -@ 4 -bS > ${sample_name}_${col3}_notCombined.bam"
    cmd_short="bowtie2 -x ${index_dir_path}/short -p 4 --end-to-end -k 2 -U ${input_path}/${sample_name}_${col3}.fq.gz | samtools view -@ 4 -bS > ${sample_name}_${col3}.bam"
    if [[ $sample_name == L* ]]
    then 
        command=${cmd_long_1}"; "${cmd_long_2}
    elif [[ $sample_name == S* ]]
    then
        command=${cmd_short}
    fi
    script="#!/bin/bash
#SBATCH -p RM-shared
#SBATCH --ntasks-per-node=4
#SBATCH -t 01:00:00
#SBATCH -A bio200049p
#SBATCH -J bowtie2
#SBATCH -o bowtie_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH

$command
echo 'Bam files generated!'
"

    script_name="bowtie_${sample_name}_${col3}.sh"
    echo "$script" > "$4/sb_scripts/$script_name"
done

echo "scripts generated!"
