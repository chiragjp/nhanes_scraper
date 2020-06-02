
num_chunks = 821
for r in range(1, num_chunks+1):
	print 'bsub -q short -W 0:10 -o ' + str(r) +  '.out Rscript merge_data_tables.R -x ' + str(r)


