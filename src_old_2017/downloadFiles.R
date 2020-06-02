# downloadFiles.R
# 3/17/2016
# read in a data table, create a URL, and download the data file
toDownload <- read.csv('./all_variable_descriptions/not_in_db.csv')
urlHead <- 'https://wwwn.cdc.gov/Nchs/Nhanes/'
destination <- './data_files'
for(ii in 1:nrow(toDownload)) {
  rw <- toDownload[ii, ]
  filename <- sprintf('%s.XPT', rw$Data.File.Name)
  survey <- sprintf('%i-%i/%s', rw$Begin.Year, rw$EndYear, filename)
  url <- sprintf('%s%s', urlHead, survey)
  outfile <- file.path(destination, filename)
  cat(sprintf('from: %s to: %s\n', url, outfile))
  download.file(url, outfile)
}