#!/usr/bin/env python

import os
import sys

infile = sys.argv[1]

def rename_files(file):
    basename = os.path.basename(file)
    parts = basename.split("_")
    if len(parts) >= 4:
        sample = parts[0]
        pair = parts[3]
        new_filename = f"{sample}_{pair}.fastq.gz"
        os.rename(file, new_filename)
        # print(f"Renamed {file} to {new_filename}")



rename_files(infile)