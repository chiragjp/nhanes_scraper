## Download the .xpt files from a source .csv.
## The source .csv is copied from the NHANES website in Chrome using the Table Capture extension:
## https://chrome.google.com/webstore/detail/table-capture/iebpjdmgckacbodjpijphcplhebcmeop/reviews
## Source website is here:
## https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Questionnaire&CycleBeginYear=2015

library(readr)
library(stringr)

demo_tables <- read_csv('./csv_grab/demo_tables.csv')
exam_tables <- read_csv('./csv_grab/exam_tables.csv')
diet_tables <- read_csv('./csv_grab/diet_tables.csv')
question_tables <- read_csv('./csv_grab/questionnaire_tables.csv')
lab_tables <- read_csv('./csv_grab/lab_tables.csv')


directory <- './xpt'
get_xpt_files <- function(nhanes_scraped_table_information, outpath) {
  data_file_var <- nhanes_scraped_table_information$`Data File`
  for(data_file in data_file_var) {
    url_to_file <- str_extract(data_file, "\\([^()]+\\)")[[1]]
    url_to_file <- substr(url_to_file, 2, nchar(url_to_file)-1)
    print(url_to_file)
    path_to_save <- file.path(outpath, tolower(basename(url_to_file)))
    download.file(url_to_file, path_to_save)
  }
}

get_xpt_files(demo_tables, file.path(directory, 'demo'))
get_xpt_files(exam_tables, file.path(directory, 'exam'))
get_xpt_files(diet_tables,file.path(directory, 'diet'))
get_xpt_files(lab_tables,file.path(directory, 'lab'))
get_xpt_files(question_tables,file.path(directory, 'question'))