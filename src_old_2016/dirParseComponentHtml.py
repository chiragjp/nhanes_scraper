### go through directory and parse the nhanes_directory_files by calling the script
import sys
from os import listdir
from os.path import isfile, join

directory = sys.argv[1]

onlyfiles = [f for f in listdir(directory) if isfile(join(directory, f))]

for filename in onlyfiles:
    path = join(directory, filename)
    if path.endswith('html'):
        print 'python' + 'parseNHANESComponentDirectoryHtml.py ' + path