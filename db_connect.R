library(RMySQL)
getConnection <- function() {
	#con <- dbConnect(MySQL(), user="cp179", password="cyljUst9", host = 'mysql.orchestra', dbname="patel_nhanes")
	con <- dbConnect(MySQL(), user="cjp", password="cjp", dbname="nhanes")
	return(con)
}
