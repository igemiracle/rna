#!usr/bin/python

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

input_file = '/Users/jingl1/Desktop/CMU/summer project/rethepathofrawdata/cwr_humanUTRset_clean_long.fa'
output_file = 'cwr_humanUTRset_clean_long.fa'
replace_spaces_in_fasta(input_file, output_file)