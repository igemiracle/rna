#!usr/bin/bash
# 只关注long文库

#arg 1: fastq raw data dir path
#arg 2: output path
echo "start"

dir="$1"

# mkdir of sbatch scripts
mkdir -p $2"/sb_scripts"

for file in "$dir"/L*.gz    #!!! only focus on L!
do
    file=$(basename "$file")
    if [ -f $1"/"$file ]; then
        filename=$(basename "$file")
        endwith=${filename##*.}
        if [ "$endwith" = "gz" ]; then
            sample_name=$(echo "$filename" | cut -d'_' -f1)
            # write into a sbatch file
            script_name="flash_${sample_name}.sh"
            cat <<EOT > $2"/sb_scripts/"$script_name
#!/bin/bash
#SBATCH -p RM-shared
#SBATCH --ntasks-per-node=8
#SBATCH -t 02:00:00
#SBATCH -A bio200049p
#SBATCH -J flash
#SBATCH -o flash_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH
flash2 -O -t 8 -M 150 -o ${sample_name} $1/${sample_name}_R2_001.fastq.gz $1/${sample_name}_R1_001.fastq.gz

EOT
        fi
    fi
done

echo "write done!"

#cutadapt -j 8 -e 0 --trimmed-only -O 26 -a $three_end_barcode -o $2/${sample_name}.3PCut.fastq $2/${sample_name}.extendedFrags.fastq
#cutadapt -j 8 -e 0 --trimmed-only -O 26 -a $three_end_barcode -o $2/${sample_name}.3PCut_1.fastq -p $2/${sample_name}.3PCut_2.fastq $2/${sample_name}.notCombined_1.fastq $2/${sample_name}.notCombined_2.fastq
