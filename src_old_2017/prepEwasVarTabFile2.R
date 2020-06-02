

### another file to get information about variables based on what already exists in the ewas_var_tab table

library('getopt')
source('db_connect.R')
source('is_categorical.R')
spec = matrix(c('table_name', 't', 1, 'character', 
                'outdirectory', 'd', 1, 'character'
                ),nrow=2, byrow=TRUE);
opt = getopt(spec)
con <- getConnection()

tableName <- opt$table_name #'phthte_f'
outdirectory <- opt$outdirectory

cat(sprintf('TABLENAME:%s\n', tableName))

sql <- sprintf('select * from nh_var_tab where tab_name = \'%s\'', tableName)
nhVarTab <- dbGetQuery(con, sql)
nhVarDesc <- dbGetQuery(con, 'select * from ewas_var_tab_combined')

commentVarForVarname <- function(varname, varnameList) {
  lastPart <- paste(substr(varname, 4, 20), 'LC', sep="")
  commentVars <- varnameList[grep('LC$',varnameList)]
  if(sum(lastPart == substr(commentVars, 4, 20))) {
    return ( commentVars[lastPart == substr(commentVars, 4, 20)] )
  }
  return(NA)
}

isWeight <- function(varname) {
  as.integer(substr(varname, 1,2 ) == 'WT')
}

isComment <- function(varname) {
  as.integer(grepl('LC$', varname))
}


isCommentDescription <- function(variableDescription) {
  as.integer(grepl('comment$', tolower(variableDescription)))
}


isQuestionnaire <- function(varname) {
  as.integer(varname != 'SEQN' & (substr(varname, 3,3) == 'Q' | nhVarTab$module[1] == 'questionnaire'))
}

nhVarTab[, 'comment_var'] <- NA
for(ii in 1:nrow(nhVarTab)) {
  nhVarTab[ii, 'comment_var'] <- commentVarForVarname(nhVarTab$var[ii], nhVarTab$var)
}


## now check if categorical...
exists <- c()
for(ii in 1:nrow(nhVarTab)) {
  cat(sprintf('Variable:%s\n', nhVarTab$var[ii]))
  arr <- getVariableArray(con, nhVarTab$var[ii], nhVarTab$tab_name[ii])
  if(is.null(arr)) {
    exists <- c(exists, 0)
    next
  } else {
    exists <- c(exists, 1)
  }
  cateVar <- categorical(arr)
  
  if(!is.null(cateVar)) {
    nhVarTab[ii, 'categorical_ref_group'] <- cateVar$categorical_ref_group
    nhVarTab[ii, 'categorical_levels'] <- cateVar$levels
  }
}

done <- dbDisconnect(con)

nhVarTab[, 'is_weight'] <- isWeight(nhVarTab$var)
nhVarTab[, 'is_comment'] <- isComment(nhVarTab$var) + isCommentDescription(nhVarTab$var_desc)
nhVarTab[nhVarTab$is_comment > 1, 'is_comment'] <- 1
nhVarTab[, 'is_questionnaire'] <- isQuestionnaire(nhVarTab$var)



nhVarTab[, 'var_desc_ewas'] <- nhVarTab[, 'tab_name']
nhVarTab[, 'tab_desc_ewas'] <- nhVarTab[, 'tab_name']

nhVarTab$analyzable <- 0
nhVarTab$analyzable[nhVarTab$is_comment == 0 & nhVarTab$is_weight == 0 & exists == 1] <- 1
nhVarTab$is_ecological <- 0
nhVarTab$is_binary <- 0 ### still need a way of determining this! (may not be relevant)
nhVarTab$is_ordinal <- 0
nhVarTab$var_desc_ewas_sub <- NA

nhVarTab <- nhVarTab[nhVarTab$var != 'SEQN', ]
### first get the default var_desc_ewas for the table
tabNameGeneral <- strsplit(tableName, '_')[[1]][1]
hasTable <- grep(tabNameGeneral, nhVarDesc$tab_name)
if(length(hasTable) > 0) {
  nhVarTab[, 'var_desc_ewas'] <- nhVarDesc[hasTable[1], 'var_desc_ewas']
  nhVarTab[, 'tab_desc_ewas'] <- nhVarDesc[hasTable[1], 'var_desc_ewas']
}

### now check if variables exist for the ones to upload
varnames <- nhVarTab$var
for(v in varnames) {
  existingVariableInfo <- subset(nhVarDesc, var == v)
  if(nrow(existingVariableInfo) > 0) {
    nhVarTab[nhVarTab$var == v, 'var_desc_ewas'] <- existingVariableInfo$var_desc_ewas[1]
    nhVarTab[nhVarTab$var == v, 'var_desc_ewas_sub'] <- existingVariableInfo$var_desc_ewas_sub[1]
    nhVarTab[nhVarTab$var == v, 'tab_desc_ewas'] <- existingVariableInfo$tab_desc_ewas[1]
  }
}

write.csv(file=file.path(outdirectory, sprintf('%s_ewas_var_tab.csv', tableName)), nhVarTab, row.names=F)

