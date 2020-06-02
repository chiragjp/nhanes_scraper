## Chirag 
## rbind the data to the large NHANES data.frame
## 12/30/18

library(tidyverse)
main <- readRDS('./xpt/merged.RDS')
main <- main[, -c(1219, 1321, 1326, 1355)] # remove redundant columns `WTSB2YR`, `WTSA2YR`

diet <- readRDS('./xpt/hei_diet.RDS')
redundant_cols <- setdiff(intersect(colnames(diet), colnames(main)), 'SEQN')
littleData <- left_join(main, diet %>% select(-redundant_cols), by='SEQN')

load('~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_schema_merged_all_hei_011818.Rdata')

littleData <- as_tibble(littleData)
bigData <- as_tibble(bigData)
inCommon <- intersect(colnames(bigData), colnames(littleData))
typesInBigData <- sapply(bigData[, inCommon], class)
typesInLittleData <- sapply(littleData[, inCommon], class)

temp <- bigData[, inCommon[(typesInBigData != typesInLittleData)]]
bigData[, inCommon[(typesInBigData != typesInLittleData)]] <- data.frame(lapply(temp, as.character), stringsAsFactors=FALSE)

temp <- littleData[, inCommon[(typesInBigData != typesInLittleData)]]
littleData[, inCommon[(typesInBigData != typesInLittleData)]] <- data.frame(lapply(temp, as.character), stringsAsFactors=FALSE)

bigData <- bind_rows(bigData, littleData)

saveRDS(bigData, file='./xpt/rbind_merged_9916.RDS')
