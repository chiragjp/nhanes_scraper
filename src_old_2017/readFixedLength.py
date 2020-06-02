import sys
filename = sys.argv[1]
import csv
spamWriter = csv.writer(sys.stdout, delimiter=',',quotechar='|', quoting=csv.QUOTE_MINIMAL, lineterminator="\n")

## remove the '.'
def dotRemove(elemArr):
	for ii in range(len(elemArr)):
		if(elemArr[ii].find(".") > -1):
			elemArr[ii] = "NA"
	return(elemArr)

spamWriter.writerow(['SEQN', 'ELIGSTAT', 'MORTSTAT', 'PERMTH_INT', 'PERMTH_EXM', 'CAUSE_AVL', 'UCOD', 'DIABETES', 'HYPERTEN', 'MORTSRCE_NDI', 'MORTSRCE_CMS', 'MORTSRCE_SSA', 'MORTSRCE_DC', 'MORTSRCE_DCL'])	

for line in open(filename):
	seqn = line[0:5].strip()
	eligStat = line[14].strip()
	mortStat = line[15].strip()
	mortSrceNdi = line[49].strip()
	mortSrceCms = line[50].strip()
	mortSrceSsa = line[51].strip()
	mortSrceDc = line[52].strip()
	mortSrceDcl = line[53].strip()
	perMthInt = line[43:46].strip()
	perMthExm = line[46:49].strip()
	causeAvl = line[16].strip()
	uCod= line[17:20].strip()
	diabetes=line[20].strip()
	hyperten=line[21].strip()
	toWrite = dotRemove([eligStat, mortStat,  perMthInt,perMthExm, causeAvl, uCod, diabetes,hyperten,mortSrceNdi, mortSrceCms,mortSrceSsa, mortSrceDc, mortSrceDcl])
	toWrite.insert(0,int(seqn))
	spamWriter.writerow(toWrite)