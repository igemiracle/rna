#!usr/bin/bash
# example: bash ../../scripts/submit.sh /ocean/projects/bio200049p/yzheng9/test/02_Cutadapt/

#$1=/ocean/projects/bio200049p/yzheng9/test

for sbatch_script in "$1/sb_scripts/"*.sh; do
    echo "Submitting $sbatch_script..."
    sbatch $sbatch_script
done