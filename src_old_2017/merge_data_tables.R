## merge all NHANES table into a large R data frame
## Chirag J Patel
## 3/17/16

library(dplyr)
load('nhanes_schema.Rdata')


tabSeries <- distinct(tabDesc, tab_name)[, c('tab_name', 'series')]
tabSeries$series_index <- 1 #a
tabSeries$series_index[tabSeries$series=='2001-2002'] <- 2 #b
tabSeries$series_index[tabSeries$series=='2003-2004'] <- 3 #c
tabSeries$series_index[tabSeries$series=='2005-2006'] <- 4 #d
tabSeries$series_index[tabSeries$series=='2007-2008'] <- 5 #e
tabSeries$series_index[tabSeries$series=='2009-2010'] <- 6 #f
tabSeries$series_index[tabSeries$series=='2011-2012'] <- 7 #g
tabSeries$series_index[tabSeries$series=='2013-2014'] <- 8 #h

bigData <- NULL
for(ii in 1:length(demoTables)) {
  cat(sprintf('%i\n', ii))
  cohortTables <- subset(tabSeries, series_index==ii)
  seriesTables <- otherTables[which(tableNames %in% cohortTables$tab_name)]
  seriesTables <- c(demoTables[ii], seriesTables)
  newTab <- plyr::join_all(seriesTables, by='SEQN', type='left')  
  if(ii == 1) {
    bigData <- newTab
  } else {
    bigData <- bind_rows(bigData, newTab)
  }
}

bigData <- left_join(bigData, bind_rows(mortTables), by='SEQN')

#ohxden_c	OHX02CSC	Coronal Caries: Surface condition #2
#ohxdent	OHX02CSC	Coronal Caries: Surface condition #2 , BIGINT
#ohxden_g	OHX02CSC	Coronal Caries: Surface condition #2

save(bigData, tabDesc, tableNames, file='nhanes_schema_merged.Rdata')
