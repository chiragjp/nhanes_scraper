## remove dups, ugh

source('db_connect.R')
sql <- "select table_name, count(table_name) from nhanes_table_description  group by table_name"
dupTable <- dbGetQuery(con, sql)
duplicates <- dupTable[dupTable[, 2] > 1, ]

sql <- 'select * from nhanes_table_description'
allTables <- dbGetQuery(con, sql)
dupTables <- allTables[allTables$table_name %in% duplicates$table_name,  ]


nonDup <- data.frame()
for(ii in 1:nrow(duplicates)) {
  tableName <- duplicates[ii, 1]
  nonDup <- rbind(nonDup, subset(dupTables, table_name == tableName)[1, ])
}

for(ii in 1:nrow(duplicates)) {
  sql <- sprintf('delete from nhanes_table_description where table_name = \'%s\'', duplicates[ii, 1])
  cat(sprintf('%s;\n', sql))
  #dbSendQuery(con, sql)
}

dbWriteTable(con, 'nhanes_table_description', nonDup, append=TRUE, row.names=FALSE, overwrite=FALSE)