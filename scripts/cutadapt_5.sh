#!usr/bin/bash
# @yzheng9 This script is to read in a TXT file, iterate line, and write into a sbtach script

# example: bash ../rna/scripts/cutadapt_5.sh ../testdata/HUTR-lib-master-list.txt /ocean/projects/bio200049p/yzheng9/test/01_Flash_Cut /ocean/projects/bio200049p/yzheng9/test/02_Cutadapt


# $1 barcode file
# $2 fastq dir full path
# $3 output path

three_end_barcode="AGATCTGTGATTAAGCCC"
rc_three_end_barcode="GGGCTTAATCACAGATCT"
control_barcode="AGCGATCAAGCTTCAGATC"

# mkdir of sbatch scripts
mkdir -p $3"/sb_scripts"

previous_sample_name=""

# read the txt file and process it, skip the header
tail -n +2 $1 | awk -F'\t' '{print $2, $3, $7}' | while read -r col2 col3 col7
do
    sample_name="$col2"
    five_end_barcode=${col7:19:17}
    cmd1="cutadapt -j 4 -e 0 --discard-untrimmed -O 12 -a $three_end_barcode -o $3/${sample_name}_${col3}_3E.fq $2/${sample_name}.extendedFrags.fastq"
    cmd2="cutadapt -j 4 -e 0 --discard-untrimmed -O 12 -g $five_end_barcode  -o $3/${sample_name}_${col3}.fq.gz $3/${sample_name}_${col3}_3E.fq"
    
    cmd2_control="cutadapt -j 4 -e 0 --discard-untrimmed -O 12 -g $five_end_barcode  -o $3/${sample_name}_${col3}_35.fq $3/${sample_name}_${col3}_3E.fq"
    cmd3_control="cutadapt -j 4 -e 0 --discard-untrimmed -O 12 -g $control_barcode  -o $3/${sample_name}_${col3}.fq.gz $3/${sample_name}_${col3}_35.fq"

    cmd1_pair="cutadapt -j 4 -e 0 --discard-untrimmed --pair-adapters -O 12 -G $rc_three_end_barcode -g $five_end_barcode -o $3/${sample_name}_${col3}_R1.fq.gz -p $3/${sample_name}_${col3}_R2.fq.gz $2/${sample_name}.notCombined_1.fastq $2/${sample_name}.notCombined_2.fastq"
    cmd1_pair_control="cutadapt -j 4 -e 0 --discard-untrimmed --pair-adapters -O 12 -G $rc_three_end_barcode -g $five_end_barcode -o $3/${sample_name}_${col3}_R1_35.fq -p $3/${sample_name}_${col3}_R2_35.fq $2/${sample_name}.notCombined_1.fastq $2/${sample_name}.notCombined_2.fastq"
    cmd2_pair_control="cutadapt -j 4 -e 0 --discard-untrimmed -O 12 -g $control_barcode -o $3/${sample_name}_${col3}_R1.fq.gz -p $3/${sample_name}_${col3}_R2.fq.gz $3/${sample_name}_${col3}_R1_35.fq $3/${sample_name}_${col3}_R2_35.fq"

    script="#!/bin/bash
#SBATCH -p RM-shared
#SBATCH --ntasks-per-node=4
#SBATCH -t 2:00:00
#SBATCH -A bio200049p
#SBATCH -J cutadapt
#SBATCH -o cutadapt_${sample_name}.o

module load anaconda3/2022.10
source /ocean/projects/bio200049p/yzheng9/rna_env/bin/activate
export LD_LIBRARY_PATH=/ocean/projects/bio200049p/yzheng9/rna_env/lib:\$LD_LIBRARY_PATH
"
    command="
$cmd1
$cmd2
rm $3/${sample_name}_${col3}_3E.fq
$cmd1_pair
echo 'Done!'
"

    command_control="
$cmd1
$cmd2_control
$cmd3_control
rm $3/${sample_name}_${col3}_3E.fq $3/${sample_name}_${col3}_35.fq
$cmd1_pair_control
$cmd2_pair_control
rm $3/${sample_name}_${col3}_R1_35.fq $3/${sample_name}_${col3}_R2_35.fq
echo 'Done!'
"

    if [ "$sample_name" != "$previous_sample_name" ]
    then
        script_name="cutadapt_${sample_name}.sh" # _${col3}.sh
        echo "$script" > "$3/sb_scripts/$script_name"
    else
        script_name="cutadapt_${sample_name}.sh" # _${col3}.sh
    fi

    if [ "${sample_name:2:1}" == "C" ]    #L1CLB/L1CIN/L2CLB/L2CIN
    then
        echo "$command_control" >> "$3/sb_scripts/$script_name"
    else
        echo "$command" >> "$3/sb_scripts/$script_name"
    fi
    previous_sample_name="$sample_name"

done

echo "scripts generated!"