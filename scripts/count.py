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
bestMatch = re.compile(r"\b([1-9][0-9]?|100)M\b")

# Open file
bamfile = pysam.AlignmentFile(bamfile_path, 'rb')

# Make a dictionary to store the constructs; key: readID(col1), value: construct(col3)
map = {}
# pysam.AlignmentFile.fetch automatically skip the header
for read in bamfile:
    readID = read.query_name
    # get the CIGAR string
    cigar = read.cigarstring
    # get the construct rname
    construct = read.reference_name
    
    # if the CIGAR string matches the pattern
    if cigar and bestMatch.search(cigar):
        # check if the read is in the dictionary
        if readID in map:
            # if the read is in the dictionary, delete it
            del map[readID]
        else:
            # if the read is not in the dictionary, add it
            map[readID] = construct

# Count the number of readIDs for each construct
count = {}
for readID, construct in map.items():
    if construct in count:
        count[construct] += 1
    else:
        count[construct] = 1

# Make a table, with the construct as the first column and the number of readIDs as the second column
with open(output_file, 'w') as table:
    table.write("Construct\tCount\n")
    for construct, num in count.items():
        table.write(construct + '\t' + str(num) + '\n')
    
# Close the file    
bamfile.close()

print("Done!")

                
        

