## Chirag J Patel
## 3/18/16
## appends .Rdata files together produced by merge_data_tables.R
directory <- './merge'
files <- dir(directory, '*.Rdata')
load(file.path(directory, files[1]))
cols <- colnames(retData)
write.csv(retData[, cols], file='nhanes_merged.csv', col.names = T, row.names = F, append = F)
for(ii in 2:length(files)) {
  load(file.path(directory, files[ii]))
  cat(sprintf('%i:%i\n', ii, nrow(retData)))
  write.csv(retData[, cols], file='nhanes_merged.csv', col.names = F, row.names = F, append = T)
}
