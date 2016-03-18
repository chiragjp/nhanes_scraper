
### This is now outdated as of 3/17/16
### see readXptAndUpload2.R
## gets the xpt file.
## gets the parsed meta data.
## writes the table into nh_var_tab table
library(getopt)
source('db_connect.R')
spec <- matrix(c('datafile', 'x', 1, 'character',
				'metafile', 'm', 1, 'character'),
				nrow=2, byrow=TRUE);
opt = getopt(spec)
con <- getConnection()
library(foreign)

print(opt$metafile)
print(opt$datafile)

xport <- read.xport(opt$datafile)
metaData <- read.csv(opt$metafile, stringsAsFactors=F)
tableName <- metaData[1, 'tab_name']

dbWriteTable(con, tableName, xport, row.names=F, append=F, overwrite=T)

table_desc <- unique(metaData[, c('tab_name', 'tab_desc','series', 'module')])
colnames(table_desc) <- c('table_name', 'description', 'series_name', 'module_name')
dbWriteTable(con, 'nhanes_table_description', table_desc, row.names=F, append=T, overwrite=F)

var_desc <- metaData[, c('tab_name', 'var', 'var_desc')]
colnames(var_desc) <- c('table_name', 'variable_name', 'description')
dbWriteTable(con, 'nhanes_variable_description', var_desc, row.names=F, append=T, overwrite=F)
done <- dbDisconnect(con)