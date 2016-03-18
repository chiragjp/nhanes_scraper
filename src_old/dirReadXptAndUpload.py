## outdated as of 3/17/2016
## see dirReadXptAndUpload.R

import sys, csv
from os import listdir
from os.path import isfile, join


sourceFilename = sys.argv[1] # nhanes_directory_files.tsv
directory = sys.argv[2]

reader = csv.reader(open(sourceFilename, 'rb'), delimiter='\t')
for r in reader:
	description = r[0]
	docFile = r[1]
	dataFile = r[2]
	module = r[-1]  
	filepath = join(directory, docFile.split('/')[-1])
	csvname = docFile.split('/')[-1].split('.')[-2].lower() + ".csv"
	xptfile = join(directory, dataFile.split('/')[-1])
	metafile = join(directory, csvname)
	print 'Rscript readXptAndUpload.R -x ' + xptfile + ' -m ' + metafile
