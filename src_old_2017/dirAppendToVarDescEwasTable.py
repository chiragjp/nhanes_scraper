import sys, os, os.path

sourceDirectory = sys.argv[1] # ewas_var_desc_files

files = os.listdir(sourceDirectory)

for filename in files:
	print 'Rscript appendToVarDescEwasTable.R -f ' + os.path.join(sourceDirectory, filename)

# Rscript appendToVarDescEwasTable.R -f filename
