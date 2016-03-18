## look in the data files directory and create a script for input using readXptAndUpload2.R

dataFileDirectory <- './data_files'
files <- dir(dataFileDirectory, pattern = '.XPT')
for(ii in 1:length(files)) {
  filename <- files[ii]
  cat(sprintf('Rscript readXptAndUpload2.R -x %s\n', file.path(dataFileDirectory, filename)))
}