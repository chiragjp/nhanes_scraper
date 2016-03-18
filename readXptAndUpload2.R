## readXptAndUpload2.R
## gets the xpt file.
## gets the parsed meta data from the catalog in ./all_variable_descriptions/combined_catalog.csv file
## writes the table into nh_var_tab table
library(getopt)
library(dplyr)
library(foreign)
source('db_connect.R')

spec <- matrix(c('datafile', 'x', 1, 'character'),nrow=1, byrow=TRUE)
opt <- getopt(spec)
con <- getConnection()
print(opt$datafile)
xport <- read.xport(opt$datafile)

allVariableDescriptions <- as_data_frame(read.csv('./all_variable_descriptions/combined_catalog.csv'))
dataFile <- unlist(strsplit(basename(opt$datafile), '\\.'))[1]
metaData <- allVariableDescriptions[allVariableDescriptions$Data.File.Name  == dataFile, ]
if(nrow(metaData) == 0) {
  cat(sprintf('filename:%s not found in catalog!', dataFile ))
  q()
}

tableName <- tolower(dataFile)
print(tableName)
dbWriteTable(con, tableName, xport, row.names=F, append=F, overwrite=T)

colnames(metaData) <- c('var', 'var_desc', 'tab_name', 'tab_desc', 'byear', 'eyear', 'module', 'constraints')
metaData$series <- sprintf('%i-%i', metaData$byear, metaData$eyear)
metaData$tab_name <- tolower(metaData$tab_name)

table_desc <- as.data.frame(distinct(metaData[, c('tab_name', 'tab_desc','series', 'module')]), tab_name)
colnames(table_desc) <- c('table_name', 'description', 'series_name', 'module_name')
dbWriteTable(con, 'nhanes_table_description', table_desc, row.names=F, append=T, overwrite=F)

var_desc <- as.data.frame(metaData[, c('tab_name', 'var', 'var_desc')])
colnames(var_desc) <- c('table_name', 'variable_name', 'description')
dbWriteTable(con, 'nhanes_variable_description', var_desc, row.names=F, append=T, overwrite=F)
done <- dbDisconnect(con)