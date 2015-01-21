import sys, csv, os.path

#filename = sys.argv[1]
filepath = sys.argv[1]
filename = os.path.basename(filepath)
tablename = filename.split('.')[0].lower()
tabledesc = sys.argv[2]
module = sys.argv[3]

seriesString = tablename.split('_')[1]

def seriesFromString(letter):
	letter = letter.lower()
	if letter == 'a':
		return('1999-2000')
	if letter == 'b':
		return('2001-2002')
	if letter == 'c':
		return('2003-2004')
	if letter == 'd':
		return('2005-2006')
	if letter == 'e':
		return('2007-2008')
	if letter == 'f':
		return('2009-2010')
	
	return None

def isComment(varname):
	if len(varname) > 4:
		return varname.endswith('LC')
	return False

def isWeight(varname):
	return(varname.startswith('WT'))


def returnBinary(boolean):
	if boolean:
		return 1
	return 0

series = seriesFromString(seriesString)
writer = csv.writer(sys.stdout, delimiter=',')
from bs4 import BeautifulSoup
soup = BeautifulSoup(open(filepath))

codeLinks = soup.find(id="CodebookLinks")
## get all ahrefs
header = ['tab_name','tab_desc', 'var', 'var_desc','module', 'series' , 'is_comment', 'is_weight']
writer.writerow(header)
hrefs = codeLinks.find_all('a')
for link in hrefs:
	variableDesc = link.get_text()
	arr = variableDesc.split()
	varname = arr[0].strip()
	## check if comment
	## check if weight
	ifComm = returnBinary(isComment(varname))
	ifWeight = returnBinary(isWeight(varname))
	varnameDesc = ' '.join(arr[2:])
	toPrint = [tablename, tabledesc, varname,varnameDesc, module, series, ifComm, ifWeight]
	writer.writerow(toPrint)
	
## need to output the tablename 
## need to output the series
## need to output the module

