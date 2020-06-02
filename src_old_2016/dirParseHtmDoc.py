import sys
from os import listdir
from os.path import isfile, join
import csv

sourceFilename = sys.argv[1] # nhanes_directory_files.tsv
directory = sys.argv[2]

reader = csv.reader(open(sourceFilename, 'rb'), delimiter='\t')
for r in reader:
    description = r[0]
    docFile = r[1]
    module = r[-1]
    filepath = join(directory, docFile.split('/')[-1])
    csvname = docFile.split('/')[-1].split('.')[-2].lower() + ".csv"
    print 'python parseNHANESHtmlDoc.py ' + filepath + " '" + description + "' " + module + ' > ' + join(directory, csvname)