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

mortalityNames <- c('mort_2010_a', 'mort_2010_b', 'mort_2010_c', 'mort_2010_d', 'mort_2010_e', 'mort_2010_f')
mortTables <- (lapply(mortalityNames, function(d) {
  as_data_frame(dbGetQuery(con, sprintf('select * from %s', d)))
}))


tabDesc <- as_data_frame(dbGetQuery(con, 'select * from ewas_var_tab_combined'))
tabDesc[tabDesc$var_desc_ewas == "blood   ", 'var_desc_ewas'] <- 'blood'
# 
#### create a table that has the rest of the information
tabDesc <- subset(tabDesc, analyzable == 1)
tabDesc.orig <- tabDesc
tabTable <- table(tabDesc$var_desc_ewas)
#leaveOutDesc <- c('supplement', 'supplement use', 'vision', 'audiometry', 'food component recall', 'pharmaceutical') ## add in the supplements with specfic tables, see below
leaveOutDesc <- c('supplement', 'supplement use', 'vision', 'audiometry', 'pharmaceutical') ## add in the supplements with specfic tables, see below
leaveOutTabnames <- c('pstpol_d', 'doxpol_e', 'pcbpol_d', 'pcbpol_e', 'doxpol_d', 'bfrpol_e', 'ssbfr_b', 'sspst_b', 'bfrpol_d', 'sspcb_b', 'pstpol_e')
leaveOutTabnames <- c(leaveOutTabnames, 'drxfcd_c', 'drxfcd_f', 'drxfcd_g', 'drxmcd_f', 'drxmcd_g')
repeatedMeasureTables <- c('dxx', 'dxx_b', 'dxx_c', 'dxx_d', 'ffqdc_c', 'ffqdc_d', 'paqiaf', 'paqiaf_b', 'paqiaf_c', 'paqiaf_d', 'ds1ids_g', 'ds2ids_g','sshpv_f' )
weirdDentalTable <- c('ohxden_g')
leaveOutTabnames <- c(leaveOutTabnames, demoNames, repeatedMeasureTables, weirdDentalTable)
tabDesc <- tabDesc[!(tabDesc$var_desc_ewas %in% leaveOutDesc), ]
tabDesc <- tabDesc[!(tabDesc$tab_name %in% leaveOutTabnames), ]
tabDesc <- tabDesc[-grep('iff', tabDesc$tab_name), ]

keepTablesSupplements <- c('ds1tot_e', 'ds2tot_e', 'ds1tot_f', 'ds2tot_f', 'ds1tot_g', 'ds2tot_g', 'dsqtot_e', 'dsqtot_f', 'dsqtot_g')
tabDesc <- rbind(tabDesc, tabDesc.orig[tabDesc.orig$tab_name %in% keepTablesSupplements, ])
tableNames <- distinct(tabDesc, tab_name)$tab_name
# 

cat(sprintf('grabbing all data for %i tables\n', length(tableNames)))
otherTables <- lapply(tableNames, function(d) {
  as_data_frame(dbGetQuery(con, sprintf('select * from %s', d)))
})


## here process the rxq tables -- these contain repeated measures for patients
pharmTableNames <- c('rxq_rx', 'rxq_rx_b', 'rxq_rx_c', 'rxq_rx_d', 'rxq_rx_e', 'rxq_rx_f', 'rxq_rx_g')
get_drug_table <- function(tableName) {
  print(tableName)
  drugTable <- as_data_frame(dbGetQuery(con, sprintf('select * from %s', tableName)))
  ## how many times drug seen in the population
  if(tableName == 'rxq_rx' | tableName  == 'rxq_rx_b') {
    drugTable$RXDUSE <- drugTable$RXD030
    drugTable$RXDDRUG <- drugTable$RXD240B
    drugTable$RXDDAYS <- drugTable$RXD260
  }
  drugTable.inuse <- subset(drugTable, RXDUSE == 1)
  prevDrugs <- names(which(table(drugTable.inuse$RXDDRUG)/sum(drugTable$RXDUSE==1, na.rm=T)*100 > 0.5)) # prevalence threshold of 0.5% of the population
  popTable <- data.frame(SEQN=unique(drugTable$SEQN))
  for(ii in 1:length(prevDrugs)) {
    onDrug <- subset(drugTable.inuse, RXDDRUG == prevDrugs[ii]) [, c('SEQN', 'RXDDAYS')]
    colnames(onDrug) <- c('SEQN', prevDrugs[ii])
    popTable <- merge(popTable, onDrug, by.x='SEQN', by.y='SEQN', all.x=T)
    popTable[is.na(popTable[, prevDrugs[ii]]), prevDrugs[ii]] <- 0 
  }
  ## clean up column names
  colnames(popTable) <- gsub("[[:punct:]]", "", colnames(popTable))
  colnames(popTable) <- gsub("[[:space:]]", "_", colnames(popTable))
  if('99999' %in% colnames(popTable) > 0) {
    popTable[, '99999'] <- NULL
  }
  return(popTable)  
}

pharmTables <- lapply(pharmTableNames, function(d) {
  get_drug_table(d)
})

## now place in tabDesc

tab_desc_pharmaceutical <- function(pharmTable, pharmTableName, surveyYear) {
  tabDesc.orig.pharm <- subset(tabDesc.orig, tab_name == 'pharmaceutical_a')[1, ]
  numVariables <- length(colnames(pharmTable))
  newRows <- tabDesc.orig.pharm[rep(seq_len(nrow(tabDesc.orig.pharm)), numVariables-1), ]
  newRows$var <- setdiff(colnames(pharmTable), 'SEQN')
  newRows$var_desc <- newRows$var
  newRows$series <- surveyYear
  newRows$tab_name <- pharmTableName
  return(newRows)
}

tabDesc <- rbind(tabDesc, 
                 tab_desc_pharmaceutical(pharmTables[[1]], pharmTableNames[1], '1999-2000'),
                 tab_desc_pharmaceutical(pharmTables[[2]], pharmTableNames[2], '2001-2002'),
                 tab_desc_pharmaceutical(pharmTables[[3]], pharmTableNames[3], '2003-2004'),
                 tab_desc_pharmaceutical(pharmTables[[4]], pharmTableNames[4], '2005-2006'),
                 tab_desc_pharmaceutical(pharmTables[[5]], pharmTableNames[5], '2007-2008'),
                 tab_desc_pharmaceutical(pharmTables[[6]], pharmTableNames[6], '2009-2010'),
                 tab_desc_pharmaceutical(pharmTables[[7]], pharmTableNames[7], '2011-2012')
)

## add to otherTables
for(ii in 1:length(pharmTables)) {
  otherTables[[length(otherTables)+1]] <- pharmTables[[ii]]
}

tableNames <- c(tableNames, pharmTableNames)

done <- dbDisconnect(con)

save(tableNames, mortTables, demoTables,demoNames, tabDesc, otherTables, file='nhanes_schema.Rdata')
