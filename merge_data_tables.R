
source('db_connect.R')
library(plyr); library(dplyr)
con <- getConnection()

## get all demo tables
demoNames <- c('demo', 'demo_b', 'demo_c', 'demo_d', 'demo_e', 'demo_f', 'demo_g', 'demo_h')
demo <- bind_rows(lapply(demoNames, function(d) {
  dbGetQuery(con, sprintf('select * from %s', d))
}))

tabDesc <- as_data_frame(dbGetQuery(con, 'select * from ewas_var_tab_combined'))
tabDesc[tabDesc$var_desc_ewas == "blood   ", 'var_desc_ewas'] <- 'blood'

#### create a table that has the rest of the information
tabDesc <- subset(tabDesc, analyzable == 1 & is_weight == 0)

#leaveOutDesc <- c( 'food component recall', 'food recall', 'oral health', 'supplement', 'supplement use', 'vision', 'audiometry')
#tabDesc <- tabDesc[-(tabDesc$var_desc_ewas %in% leaveOutDesc), ]

tableNames <- distinct(tabDesc, tab_name)$tab_name

otherTables <- lapply(tableNames, function(d) {
  dbGetQuery(con, sprintf('select * from %s', d))
})

allTables <- c(list(demo), otherTables)
otherTables <- NULL
demo <- NULL
## now do left joins with demo
bigData <- join_all(allTables, by='SEQN')
###
done <- dbDisconnect(con)
save(bigData, tabDesc)
