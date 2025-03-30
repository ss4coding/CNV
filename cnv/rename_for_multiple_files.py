#!/usr/bin/python
# -*- coding: utf-8 -*-

import os       # for getting files from directory
import sys      # for accessing command line arguments
import pandas as pd

# Get the sample_sheet_path and gene_file_paths passed from the Python master script
sample_sheet_path = sys.argv[1]
gene_file_paths=sys.argv[2]

data = pd.read_csv(sample_sheet_path, header = 0,index_col = 1)

# Display the sample sheet data
print(f"Data from {sample_sheet_path[2:]} shown below:")
print(data)

translation = {}
for original_file_name in data.index:
    new_file_name = str(data.loc[original_file_name, 'Sample ID']) +'_gdc_realn.bam'
    translation[original_file_name] = new_file_name


# List all the folder names of the genes you want to run rename.py
genes=[file_path.split('/')[-2] for file_path in gene_file_paths.split(" ")]
for gene in genes:
    directory = f'./{gene}/'
    for filename in os.listdir(directory):
        if(filename in translation.keys()):
            os.rename(directory+filename, directory+translation[filename])
        else:
            continue