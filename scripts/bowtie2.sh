#!usr/bin/bash

index="$1"
input="$2"
output_path="$3"
long_or_short="$4"

# Long index
# single end
bowtie2 -x ${index} -p 8 --end-to-end -k 2 -U ../../test_06_24/02_Cutadapt/L1CIN_Input.fq -S LICIN_Input.sam

# pair end