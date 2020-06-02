### update the data dictionary
library(tidyverse)
## this contains the old file and old merged file

load('~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_schema_merged_all_hei_011818.Rdata')
newData <- readRDS('./xpt/rbind_merged_9916.RDS')


new_variable_names <- rbind(
    read_csv('./csv_grab/demo_variables.csv'),
    read_csv('./csv_grab/exam_variables.csv'),
    read_csv('./csv_grab/lab_variables.csv'),
    read_csv('./csv_grab/question_variables.csv'),
    read_csv('./csv_grab/diet_variables.csv')
)
new_variable_names <- new_variable_names %>% rename(var=`Variable Name`, var_desc = `Variable Description`, tab_name=`Data File Name`, tab_desc=`Data File Description`)
new_variable_names <- new_variable_names %>% mutate(series=paste0(`Begin Year`, '-', EndYear))


##### fill in with known information by variable name
tabDescConcise <- tabDesc %>% 
  group_by(var) %>% 
  summarize(var_desc=first(var_desc), tab_name = first(tab_name), tab_desc=first(tab_desc),
            module=first(module), tab_desc_ewas=first(tab_desc_ewas), analyzable=first(analyzable),
            var_desc_ewas=first(var_desc_ewas), var_desc_ewas_sub=first(var_desc_ewas_sub),
            comment_var = first(comment_var), is_comment=first(is_comment), is_weight=first(is_weight),
            is_questionnaire=first(is_questionnaire), is_ecological=first(is_ecological), is_binary=first(is_binary),
            is_ordinal=first(is_ordinal), categorical_ref_group=first(categorical_ref_group), categorical_levels=first(categorical_levels)
  )

new_variable_names <- new_variable_names %>% rename(module=Component)
new_variable_names$var <- toupper(new_variable_names$var)
new_variable_names_to_bind <- new_variable_names %>% select(var, var_desc, tab_name, tab_desc,module, series)
### 
new_variable_names_to_bind <- left_join(new_variable_names_to_bind, 
  tabDescConcise[,c('var', setdiff(colnames(tabDescConcise), colnames(new_variable_names_to_bind)))])

## add the dietary variables to the list
hei_desc <- subset(tabDescConcise, tab_name == 'hei')
hei_desc$series <- '2015-2016'
new_variable_names_to_bind <-  rbind(new_variable_names_to_bind, hei_desc)
####


# now impute data
missing_information <- subset(new_variable_names_to_bind, is.na(var_desc_ewas))
new_variable_names_to_bind <- new_variable_names_to_bind %>% filter(!is.na(var_desc_ewas))
missing_information <- missing_information %>% filter(tab_name != 'GEO_2010')
missing_information <- missing_information %>% filter(tab_name != 'GEO_2000')
missing_information <- missing_information %>% filter(var != "SEQN")
missing_information <- missing_information %>% mutate(is_weight=ifelse(str_detect(var, '^WT'), 1,0 )) 
missing_information <- missing_information %>% mutate(is_comment=ifelse(str_detect(var, 'LC$'), 1,0 )) 
missing_information[missing_information [, 'tab_name'] == 'DEMO_I', 'var_desc_ewas'] <- 'demographics'
missing_information[missing_information [, 'tab_name'] == 'DEMO_I', 'analyzable'] <- 1

missing_information[missing_information$tab_name == 'BMX_I', 'var_desc_ewas'] <- 'body measures'
missing_information[missing_information$tab_name == 'BPX_I', 'var_desc_ewas'] <- 'blood pressure'
missing_information[missing_information$tab_name == 'SSHC_I_R', 'var_desc_ewas'] <- 'viral infection'

table_desc_to_impute <- missing_information %>% group_by(tab_name) %>% filter(is.na(var_desc_ewas)) %>% summarize(table_desc=first(tab_desc)) %>% rename(tab_desc = table_desc)
write_csv(table_desc_to_impute, path='./temp.csv')
## update the temp.csv and read it back in
table_desc_to_impute_updated <- read_csv('./temp.csv')
## now update var_desc_ewas
table_desc_to_impute_updated <- table_desc_to_impute_updated %>% select(-c(table_name, table_desc))
missing_information1 <- subset(missing_information, !is.na(var_desc_ewas))
missing_information2 <- subset(missing_information, is.na(var_desc_ewas))
missing_information2 <- left_join(missing_information2 %>% select(-var_desc_ewas), table_desc_to_impute_updated, by='tab_name')

tabDesc.new <- rbind(new_variable_names_to_bind,missing_information1,missing_information2)
tabDesc.new$series <- '2015-2016'
tabDesc <- rbind(tabDesc %>% select(-c(binary_ref_group,version_date)), tabDesc.new)

bigData <- newData
save(bigData, tabDesc, file='~/Dropbox (RagGroup)/RagGroup Team Folder/nhanes_merged_data/nhanes_merged_12_2018.Rdata')

