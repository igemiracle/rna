#!usr/bin/python
# Input: a bam file
# Output: a table

import pysam
import sys
import re
from collections import defaultdict

# argument
if len(sys.argv) != 2:
    print("Usage: python count.py <bamfile>")
    sys.exit(1)

bamfile_path = sys.argv[1]
sample_name = bamfile_path.split('/')[-1].split('.')[0]
output_file = sample_name + '_count.txt'

"""
# Define the regular expression pattern
# best match: [1-100]M
bestMatch = re.compile(r"\b([1-9][0-9]?|100)M\b")
"""
# Open file
# pysam.AlignmentFile.fetch automatically skip the header
bamfile = pysam.AlignmentFile(bamfile_path, 'rb')

# For combined files
def count_combined(bamfile):
    # Make a dictionary to store the constructs; key: readID(col1), value: construct(col3)
    map = {}

    for read in bamfile:

        readID = read.query_name
        # get the construct rname
        construct = read.reference_name
        """
        # get the CIGAR string
        cigar = read.cigarstring
        
        # if the CIGAR string matches the pattern
        if cigar and bestMatch.search(cigar):
            # check if the read is in the dictionary
            if readID in map:
                # if the read is in the dictionary, delete it
                del map[readID]
            else:
                # if the read is not in the dictionary, add it
            map[readID] = construct
    """
        if read.has_tag('AS'):
            as_tag = read.get_tag('AS')
            if read.has_tag('XS'):
                xs_tag = read.get_tag('XS')
                if as_tag == 0 and xs_tag != 0:
                    if readID in map:
                        del map[readID]
                    else:
                        map[readID] = construct
            elif as_tag == 0:
                    if readID in map:
                        del map[readID]
                    else:
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

# For uncombined files
def count_notCombined(bamfile):
    R1 = defaultdict(set)
    R2 = defaultdict(set)

    read_count = 0
    perfect_match_R1 = 0
    perfect_match_R2 = 0
    final_reads = 0

    for read in bamfile:
        read_count += 1
        if read.has_tag('AS'):
            as_tag = read.get_tag('AS')
            
            # if it is a best match
            readID = read.query_name
            construct = read.reference_name
            if read.is_read1:
                if as_tag == 0:
                    R1[readID].add(construct)
                    perfect_match_R1 += 1
            elif read.is_read2:
                if as_tag == 0:
                    R2[readID].add(construct)
                    perfect_match_R2 += 1

    
    # Count and output as a table
    count = defaultdict(int)
    for readID in R1:
        if readID in R2:
            if len(R1[readID]) > 1 and len(R2[readID]) == 1:
                for construct in R1[readID]:
                    if construct == next(iter(R2[readID])):
                        count[construct] += 1
                        final_reads += 1
            elif len(R1[readID]) == 1 and len(R2[readID]) > 1:
                for construct in R2[readID]:
                    if construct == next(iter(R1[readID])):
                        count[construct] += 1
                        final_reads += 1
            elif len(R1[readID]) == 1 and len(R2[readID]) == 1: 
                if R1[readID] == R2[readID]:
                    construct = next(iter(R1[readID]))
                    count[construct] += 1
                    final_reads += 1

    # Make a table, with the construct as the first column and the number of readIDs as the second column
    with open(output_file, 'w') as table:
        table.write("Construct\tCount\n")
        for construct, num in count.items():
            table.write(construct + '\t' + str(num) + '\n')
    print("read count:",read_count,"\n perfect R1,",perfect_match_R1, "\n prefect R2",perfect_match_R2,"\n final reads:",final_reads)
    

if sample_name.split('_')[-1] == 'notCombined':
    print("notCombined!")
    count_notCombined(bamfile)
else:
    print("Combined!")
    count_combined(bamfile)


# Close the file    
bamfile.close()

print("Done!")

                
        

