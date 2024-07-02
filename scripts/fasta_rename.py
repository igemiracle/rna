#!usr/bin/python

import sys

def replace_spaces_in_fasta(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith('>'):
                parts = line.rstrip('\n').split(' ')
                line = '|'.join(parts) + '\n'
                # if line ends with "|", remove it
                if line[:-1].endswith('|'):
                    line = line[:-2] + '\n'
            outfile.write(line)

input_file = sys.argv[1]
output_file = 'cwr_humanUTRset_clean_short_1.fa'
replace_spaces_in_fasta(input_file, output_file)