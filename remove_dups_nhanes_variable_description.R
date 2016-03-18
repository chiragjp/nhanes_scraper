source('db_connect.R')
sql <- "select * from (select variable_name, table_name, count(table_name) as cnt from nhanes_variable_description  group by variable_name, table_name) t where cnt > 1;"
duplicates <- dbGetQuery(con, sql)


sql <- 'select * from nhanes_variable_description'
allVariables <- dbGetQuery(con, sql)

dupVariables <- data.frame()
for(ii in 1:nrow(duplicates) ) {
  dupVariables <- rbind(dupVariables, subset(allVariables, variable_name == duplicates[ii, 'variable_name'] & table_name == duplicates[ii, 'table_name'])[1, ])
}

for( ii in 1:nrow(duplicates)) {
  sql <- sprintf('delete from nhanes_variable_description where variable_name = \'%s\' and table_name = \'%s\'', duplicates[ii, 'variable_name'], duplicates[ii, 'table_name'])
  #cat(sprintf('%s;\n', sql))
  
}

dbWriteTable(con, 'nhanes_variable_description', dupVariables, append=TRUE, row.names=FALSE, overwrite=FALSE)