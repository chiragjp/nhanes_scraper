import sys, csv

sourceFilename = sys.argv[1] # nhanes_directory_files.tsv

reader = csv.reader(open(sourceFilename, 'rb'), delimiter=',')
for r in reader:
	tableName = r[0].lower()
	print 'Rscript prepEwasVarTabFile2.R -t ' + tableName + ' -d ./ewas_var_desc_files/'

# Rscript prepEwasVarTab2.R -t tableName -d ./ewas_var_desc_files/
