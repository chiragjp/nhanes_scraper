## 1/1/2019

## Compares the exisiting data.frame with all of the variables available.
## To get a list of current variables:
### URL
## With Chrome, download the table of variables for each component and save to a .csv file

## This can be potentially helpful in indetifying what tables are required to keep the dataframe up to date.

library(tidyverse)
var_list_exam <- read_csv('./csv_grab/all_exam_variables.csv')
var_list_lab <- read_csv('./csv_grab/all_lab_variables.csv') 
var_list_question <- read_csv('./csv_grab/all_question_variables.csv')
var_list_demo <- read_csv('./csv_grab/all_demo_variables.csv')

var_list_exam <- var_list_exam %>% mutate(series=paste0(`Begin Year`, '-', EndYear)) 
var_list_question <- var_list_question %>% mutate(series=paste0(`Begin Year`, '-', EndYear))
var_list_demo <- var_list_demo %>% mutate(series=paste0(`Begin Year`, '-', EndYear))


### load in main file
load('~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_merged_12_2018.Rdata')
## 
setdiff(toupper(unique(var_list_exam$`Data File Name`)), toupper(unique(tabDesc$tab_name)))
setdiff(toupper(unique(var_list_question$`Data File Name`)), toupper(unique(tabDesc$tab_name)))
setdiff(toupper(unique(var_list_lab$`Data File Name`)), toupper(unique(tabDesc$tab_name)))

