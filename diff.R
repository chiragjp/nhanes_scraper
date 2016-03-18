## diff between the database and a list of tables from the CDC
source('db_connect.R')
library(dplyr)
con <- getConnection()
dataTablesInDb <- dbGetQuery(con, 'show tables')
done <- dbDisconnect(con)
## now read the .csv in the ./all_variable_descriptions
demoVars <- read.csv('./all_variable_descriptions/demo.csv')
examVars <- read.csv('./all_variable_descriptions/exam.csv')
labVars <- read.csv('./all_variable_descriptions/laboratory.csv')
dietaryVars <- read.csv('./all_variable_descriptions/dietary.csv')
allVariableDescriptions <- as_data_frame(bind_rows(demoVars, examVars, labVars, dietaryVars))

dataTablesAtNCHS <- distinct(allVariableDescriptions, Data.File.Name) [, c('Data.File.Name', 'Data.File.Description', 'Begin.Year', 'EndYear', 'Component', 'Use.Constraints')]
notInDb <- setdiff(tolower(dataTablesAtNCHS$Data.File.Name), tolower(dataTablesInDb$Tables_in_nhanes))
notInDbDesc <- subset(dataTablesAtNCHS[tolower(dataTablesAtNCHS$Data.File.Name) %in% notInDb, ], Use.Constraints!='RDC Only')
write.csv(notInDbDesc, file='./all_variable_descriptions/not_in_db.csv', row.names=F)
