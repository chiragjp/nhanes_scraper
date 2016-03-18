### merge all the files together
### 3/17/2016
library(dplyr)
demoVars <- read.csv('./demo.csv')
examVars <- read.csv('./exam.csv')
labVars <- read.csv('./laboratory.csv')
dietaryVars <- read.csv('./dietary.csv')
allVariableDescriptions <- as_data_frame(bind_rows(demoVars, examVars, labVars, dietaryVars))
write.csv(allVariableDescriptions, file='./combined_catalog.csv', row.names=F)