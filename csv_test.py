import csv

reader = csv.reader(open('alq_e_ewas_var_tab.csv'), delimiter=',', quotechar='\"')
firstCol = []
for row in reader:
	firstCol.append(row[5])
	


print 'first column here:'
print firstCol