## code to ascertain if variable is categorical

NUM_DISTINCT_VALUES <- 20
DISTINCT_VALUES <- c(0:15, 55, 66, 77, 99)

getVariableArray <- function(con, varname,  tabName) {
	# check if the variable is present
	colInfo <- dbGetQuery(con, sprintf('show columns from %s', tabName))
	if(sum(varname %in% colInfo$Field) == 0 ) {
	  return(NULL)
	}
	
	variableArray <- dbGetQuery(con, sprintf('select %s from %s', varname, tabName))
	return(variableArray[, 1])
}

hasDecimal <- function(array) {
	n <- length(grep('\\.', as.character(array)))
	return(n>0)
}



categorical <- function(array) {
	## check if integers
	## check number of distinct values
	if(hasDecimal(array)) {
		return(NULL)
	}
	
	tab <- table(array)
	
	if(length(tab) == 0) {
	  return(NULL)
	}
	
	inArr <- as.integer(names(tab)) %in% DISTINCT_VALUES
	if(dim(tab) < NUM_DISTINCT_VALUES & all(inArr)) {
		### return a list with the categorical_ref_group and the levels
		levs <- paste(names(tab), collapse=',')
		refGroup <- names(which.max(tab))
		return(list(categorical_ref_group=refGroup, levels=levs, level_array=names(tab)))
		
	}
	return(NULL)
}

### do some tests
# source('db_connect.R')
# con <- getConnection()
# arr1 <- getVariableArray(con, 'LBDHBG', '2005-2006')
# categorical(arr1) ## should be 1,2
# categorical(getVariableArray(con, 'BMXBMI', '2003-2004')) ## should be null
# categorical(getVariableArray(con, 'RIDRETH1', '2003-2004')) ## should be 3 / 1,2, 3, 4,5
# categorical(getVariableArray(con, 'URXBPH', '2003-2004')) ## should be NULL
# categorical(getVariableArray(con, 'DMDMARTL', '2003-2004')) ## should be 1 / 1, 2, 3, 4, 5, 6
# 
# categorical(getVariableArray(con, 'DMDEDUC', '2003-2004')) ## should be NULL



