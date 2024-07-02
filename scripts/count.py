#!usr/bin/python
# Input: a bam file
# Output: a table

import pysam
import sys
import re

# argument
if len(sys.argv) != 2:
    print("Usage: python count.py <bamfile>")
    sys.exit(1)

bamfile_path = sys.argv[1]
sample_name = bamfile_path.split('/')[-1].split('.')[0]
output_file = sample_name + '_count.txt'

# Define the regular expression pattern
# best match: [1-100]M
pattern = re.compile(r"\b([1-9][0-9]?|100)M\b")

# Open file
bamfile = pysam.AlignmentFile(bamfile_path, 'rb')

# Make a dictionary to store the constructs; key: readID(col1), value: construct(col3)
map = {}
for read in bamfile.fetch():
    readID = read.query_name
    # get the CIGAR string
    cigar = read.cigarstring
    # get the construct rname
    construct = read.reference_name
    
    # if the CIGAR string matches the pattern
    if pattern.match(cigar):
        # check if the construct exists in the dictionary
        if construct not in map:
            map[construct] = []
            # add the readID to the construct
            map[construct].append(readID)
        else:
            # check if the readID already exists in the construct
            if readID not in map[construct]:
                map[construct].append(readID)
            else:
                # delete the readID from the construct
                map[construct].remove(readID)

# Make a table, with the construct as the first column and the number of readIDs as the second column
with open(output_file, 'w') as table:
    for construct in map:
        table.write(construct + '\t' + str(len(map[construct])) + '\n')
    
# Close the file    
bamfile.close()

print("Done!")

                
        

