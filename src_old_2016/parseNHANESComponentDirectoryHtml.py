## this python file reads in a NHANES html file that contains the names and paths to all the .xpt and .html files

import sys
from bs4 import BeautifulSoup

filepath = sys.argv[1] # path to .htm document
soup = BeautifulSoup(open(filepath))

filenameArr = filepath.split("_")

component = filenameArr[-2]

def print_rowdata(rowData):
    print rowData['name'] + "\t" + rowData['doc'] + "\t" + rowData['data'] + "\t" + rowData['date'] + "\t" + rowData['component']

codeLinks = soup.find(id="PageContents_GridView1")

if codeLinks == None:
    exit(0)

rows = codeLinks.find_all('td')
counter = 0
rowData = {'component':component}
for r in rows:
    index = counter + 1
    if index % 4 == 1:
        rowData['name'] = r.get_text().strip()
    elif index % 4 == 2:
        rowData['doc'] = r.a['href'].strip()
    elif index % 4 == 3:
        rowData['data'] = r.a['href'].strip()
    else:
        rowData['date'] = r.get_text().strip()
        print_rowdata(rowData)
        rowData = {'component':component}
    counter += 1