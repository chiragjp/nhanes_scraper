library(RMySQL)
getConnection <- function() {
	con <- dbConnect(MySQL(), user="cjp", password="cjp", dbname="nhanes")
	return(con)
}
