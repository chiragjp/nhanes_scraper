load('~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_merged_12_2018.Rdata')

table(tabDesc$var_desc_ewas)
## food recall
## food component recall
## nutrients - blood nutrients

nutriNames <- tabDesc %>% filter(var_desc_ewas == 'nutrients') %>% group_by(var) %>% summarize(cnt=n())
foodRecallNames <- tabDesc %>% filter(var_desc_ewas == 'food recall') %>% group_by(var, series) %>% summarize(cnt=n()) %>% arrange(var)
foodComponentRecallNames <- tabDesc %>% filter(var_desc_ewas == 'food component recall') %>% group_by(var, series) %>% arrange(var)

## all of the above look ok, need to add the TKCAL, etc for the 2015-2016: something strange with .x, .y

colnames(bigData)[grep('\\.x',colnames(bigData))] # 1999-2000
colnames(bigData)[grep('\\.y',colnames(bigData))] # this contains everything from 2005-2014

colnames(bigData)[grep('^T', colnames(bigData))]

bigData2 <- bigData
## get colnames and merge into 1
#"TKCAL.y" "TSFAT.y" "TMFAT.y" "TPFAT.y" "TSODI.y" "TALCO.y"
bigData2$TKCAL <- rowMeans(bigData[, c("TKCAL", "TKCAL.x", "TKCAL.y")], na.rm=T)
bigData2$TSFAT <- rowMeans(bigData[, c("TSFAT", "TSFAT.x", "TSFAT.y")], na.rm=T)
bigData2$TMFAT <- rowMeans(bigData[, c("TMFAT", "TMFAT.x", "TMFAT.y")], na.rm=T)
bigData2$TPFAT <- rowMeans(bigData[, c("TPFAT", "TPFAT.x", "TPFAT.y")], na.rm=T)
bigData2$TSODI <- rowMeans(bigData[, c("TSODI", "TSODI.x", "TSODI.y")], na.rm=T)
bigData2$TALCO <- rowMeans(bigData[, c("TALCO", "TALCO.x", "TALCO.y")], na.rm=T)
table(is.na(bigData2$TKCAL), bigData$SDDSRVYR)
table(is.na(bigData2$TALCO), bigData$SDDSRVYR)

bigData2 <- bigData2 %>% select(-c(TALCO.x, TALCO.y, TKCAL.x, TKCAL.y, TSFAT.x, TSFAT.y, TMFAT.x, TMFAT.y, TPFAT.x, TPFAT.y, TSODI.x, TSODI.y))
colnames(bigData2)[grep('\\.x',colnames(bigData2))]

## now add to tabDesc and save
bigData <- bigData2
varsToAdd <- c("TKCAL","TSFAT", "TMFAT", "TPFAT", "TSODI", "TALCO")
subtab <- tabDesc %>% filter(var %in% varsToAdd & series == '2013-2014')
subtab$series <- '2015-2016'
tabDesc <- rbind(tabDesc, subtab)

save(bigData, tabDesc, file='~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_merged_12_2018.Rdata')
