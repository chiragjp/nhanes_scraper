# Chirag Patel
# 3/18/16
# gets all the data tables from the NHANES schema and dumps it into a .Rdata object

library(plyr); library(dplyr)
source('db_connect.R')
con <- getConnection()


demoNames <- c('demo', 'demo_b', 'demo_c', 'demo_d', 'demo_e', 'demo_f', 'demo_g', 'demo_h')
demoTables <- (lapply(demoNames, function(d) {
  as_data_frame(dbGetQuery(con, sprintf('select * from %s', d)))
}))


tabDesc <- as_data_frame(dbGetQuery(con, 'select * from ewas_var_tab_combined'))
tabDesc[tabDesc$var_desc_ewas == "blood   ", 'var_desc_ewas'] <- 'blood'
# 
#### create a table that has the rest of the information
tabDesc <- subset(tabDesc, analyzable == 1)
tabTable <- table(tabDesc$var_desc_ewas)
leaveOutDesc <- c('supplement', 'supplement use', 'vision', 'audiometry', 'food component recall', 'pharmaceutical')
leaveOutTabnames <- c('pstpol_d', 'doxpol_e', 'pcbpol_d', 'pcbpol_e', 'doxpol_d', 'bfrpol_e', 'ssbfr_b', 'sspst_b', 'bfrpol_d', 'sspcb_b', 'pstpol_e')
repeatedMeasureTables <- c('dxx', 'dxx_b', 'dxx_c', 'dxx_d', 'ffqdc_c', 'ffqdc_d', 'paqiaf', 'paqiaf_b', 'paqiaf_c', 'paqiaf_d', 'ds1ids_g', 'ds2ids_g','sshpv_f' )
weirdDentalTable <- c('ohxden_g')
leaveOutTabnames <- c(leaveOutTabnames, demoNames, repeatedMeasureTables, weirdDentalTable)
tabDesc <- tabDesc[!(tabDesc$var_desc_ewas %in% leaveOutDesc), ]
tabDesc <- tabDesc[!(tabDesc$tab_name %in% leaveOutTabnames), ]
tabDesc <- tabDesc[-grep('iff', tabDesc$tab_name), ]
tableNames <- distinct(tabDesc, tab_name)$tab_name
# 

cat(sprintf('grabbing all data for %i tables\n', length(tableNames)))
otherTables <- lapply(tableNames, function(d) {
  as_data_frame(dbGetQuery(con, sprintf('select * from %s', d)))
})
done <- dbDisconnect(con)

save(tableNames, demoTables,demoNames, tabDesc, otherTables, file='nhanes_schema.Rdata')
