library('getopt')
spec = matrix(c('file_name', 'f', 1, 'character'),
				nrow=1, byrow=TRUE);
opt = getopt(spec)
filename <- opt$file_name #'phthte_d_ewas_var_tab.csv'

tableName <- 'ewas_var_tab_combined_staging_3'

cat(sprintf('FILENAME:%s\n', filename))

source('db_connect.R')
con <- getConnection()

tab <- read.csv(filename)
dbWriteTable(con, tableName, tab, row.names=F, append=T, overwrite=F)

dbDisconnect(con)