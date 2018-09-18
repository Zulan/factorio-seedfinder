#!/bin/env python3
import csv
from glob import glob

seeds = []
for path in sorted(glob('**/*.csv', recursive=True)):
    print(path)
    with open(path) as csvfile:
        reader = csv.reader(csvfile)
        next(reader)
        for row in reader:
            seeds.append(int(row[0]))
            
print('seed_list = {' + ','.join([str(s) for s in seeds]) + '}')
