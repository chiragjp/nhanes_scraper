### read in a parsed directory file and download to a directory
### this is outdated (as of 3/17/2016)

import sys, csv, requests, os.path
tsvfile = open(sys.argv[1], 'rb')
outdir = sys.argv[2]
tsv = csv.reader(tsvfile, delimiter='\t')

def download_file(url,outdirectory):
    local_filename = url.split('/')[-1]
    r = requests.get(url, stream=True)
    with open(os.path.join(outdirectory, local_filename), 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024): 
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)
    return local_filename


counter = 1
for row in tsv:
    tableName = row[0]
    documentationURL = row[1]
    dataURL = row[2]
    date = row[3]
    print str(counter) + ":" + documentationURL
    download_file(documentationURL, outdir)
    print str(counter) + ":" + dataURL
    download_file(dataURL, outdir)
    counter += 1
