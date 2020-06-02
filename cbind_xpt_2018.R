library(tidyverse)
library(foreign)

todofolders <- c('exam', 'question', 'lab') # do diet later
### stitch together NHANES from an .xpt folder
demo <- read.xport('./xpt/demo/demo_i.xpt')
big_data <- list()
big_data[[1]] <- demo
for (ii in seq_along(todofolders)) {
  xptdirectory <- sprintf('./xpt/%s', todofolders[ii])
  outdataname <- sprintf('./xpt/%s.rds', todofolders[ii])
  ###
  xptfiles <- list.files(xptdirectory)
  xptpaths <- file.path(xptdirectory, xptfiles)
  frames_list <- xptpaths %>% map(~read.xport(.))
  big_data[[ii+1]] <- frames_list %>% reduce(full_join, by='SEQN')
}

big_data_merged <- big_data %>% reduce(left_join, by='SEQN')
## find redundant cols and remove/rename
big_data_merged <- big_data_merged %>% select(-ends_with('.y'))
colnames(big_data_merged) <- sub('\\.x', '', colnames(big_data_merged))
saveRDS(big_data_merged, file='./xpt/merged.RDS')




