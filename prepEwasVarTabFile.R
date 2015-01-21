library('getopt')
source('db_connect.R')
source('is_categorical.R')
spec = matrix(c('table_name', 't', 1, 'character',
				'var_desc_ewas', 'v', 1, 'character'),
				nrow=2, byrow=TRUE);
opt = getopt(spec)
con <- getConnection()


var_desc_ewas <- opt$var_desc_ewas;
tab_desc_ewas <- var_desc_ewas #'phthalates'
tableName <- opt$table_name #'phthte_d'

sql <- sprintf('select * from nh_var_tab where tab_name = \'%s\'', tableName)
nhVarTab <- dbGetQuery(con, sql)
#done <- dbDisconnect(con)

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

isQuestionnaire <- function(varname) {
	as.integer(varname != 'SEQN' & (substr(varname, 3,3) == 'Q' | nhVarTab$module[1] == 'questionnaire'))
}

nhVarTab[, 'comment_var'] <- NA
for(ii in 1:nrow(nhVarTab)) {
	nhVarTab[ii, 'comment_var'] <- commentVarForVarname(nhVarTab$var[ii], nhVarTab$var)
}


## now check if categorical...
for(ii in 1:nrow(nhVarTab)) {
	arr <- getVariableArray(con, nhVarTab$var[ii], nhVarTab$series[ii])
 	cateVar <- categorical(arr)
	#print(nhVarTab$var[ii])
	#print(cateVar)
	if(!is.null(cateVar)) {
		nhVarTab[ii, 'categorical_ref_group'] <- cateVar$categorical_ref_group
		nhVarTab[ii, 'categorical_levels'] <- cateVar$levels
	}
}



nhVarTab[, 'is_weight'] <- isWeight(nhVarTab$var)
nhVarTab[, 'is_comment'] <- isComment(nhVarTab$var)
nhVarTab[, 'is_questionnaire'] <- isQuestionnaire(nhVarTab$var)
nhVarTab[, 'tab_desc_ewas'] <- tab_desc_ewas
nhVarTab[, 'var_desc_ewas'] <- var_desc_ewas
nhVarTab$analyzable <- 0
nhVarTab$analyzable[nhVarTab$is_comment == 0 & nhVarTab$is_weight == 0] <- 1
nhVarTab$is_ecological <- 0
nhVarTab$is_binary <- 0 ### still need a way of determining this! (may not be relevant)
nhVarTab$is_ordinal <- 0
#nhVarTab$categorical_ref_group <- NA
#nhVarTab$categorical_levels <- NA
nhVarTab$var_desc_ewas_sub <- NA

nhVarTab <- nhVarTab[nhVarTab$var != 'SEQN', ]
done <- dbDisconnect(con)

write.csv(file=sprintf('%s_ewas_var_tab.csv', tableName), nhVarTab, row.names=F)

