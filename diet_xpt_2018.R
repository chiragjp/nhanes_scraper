library(tidyverse)
library(foreign)
library(hei)
library(haven)

###### This script gets the HEI, with help from the hei package. The hei get_diet needs to be modified to get the new data
demo <- read.xport('./xpt/demo/demo_i.xpt')
######### process FPED file from USDA:
######### https://www.ars.usda.gov/northeast-area/beltsville-md-bhnrc/beltsville-human-nutrition-research-center/food-surveys-research-group/docs/fped-databases/
dr1tot_fped <- read_sas('./usda_fped/fped_dr1tot_1516.sas7bdat')
dr2tot_fped <- read_sas('./usda_fped/fped_dr2tot_1516.sas7bdat')

redundant_cols <- setdiff(intersect(names(dr1tot_fped), names(dr2tot_fped)), "SEQN")
fped <- merge(dr1tot_fped, dr2tot_fped %>% select(-redundant_cols), by='SEQN')

day1cols <- grep('DR1T', colnames(fped))
day2cols <- grep('DR2T', colnames(fped))
nms <- colnames(fped)[day1cols]
for(dr1name in nms) {
  new_key <- substr(dr1name, 4, nchar(dr1name))
  dr2name <- sprintf('DR2%s', new_key)
  print(sprintf('%s,%s', dr1name, dr2name))
  ave <- rowMeans(fped[, c(dr1name, dr2name)], na.rm = T)
  fped <- fped %>% mutate(!!new_key := ave)
}

fped <- fped %>% mutate(DRSTZ = (DR1DRSTZ + DR2DRSTZ)/2)

#########
get_diet <- function (year, day) {
  yearchoices <- c(D = "2005/2006", E = "2007/2008", F = "2009/2010", 
                   G = "2011/2012", H = "2013/2014", I="2015/2016") ## added 2014-2016
  try(if (!year %in% yearchoices) 
    stop("must use valid year choice, see ?get_diet for valid choices", 
         call. = FALSE))
  daychoices <- c(DR1 = "first", DR2 = "second", "both")
  try(if (!day %in% daychoices) 
    stop("must use valid day choice, see ?get_diet for valid choices", 
         call. = FALSE))
  if (day != "both") {
    dbname <- paste0(names(which(daychoices == day)), "TOT_", 
                     names(which(yearchoices == year)))
    dat <- nhanesA::nhanes(dbname)
    names(dat) <- gsub("DR[1-9]", "", names(dat))
    keepers <- c("SEQN", "TKCAL", "TSFAT", "TALCO", "TSODI", 
                 "TMFAT", "TPFAT")
    dat <- dat[, names(dat) %in% keepers]
    dat <- data.frame(apply(dat, 2, as.numeric))
  }
  else {
    dbname1 <- paste0(names(daychoices[1]), "TOT_", names(which(yearchoices == 
                                                                  year)))
    dat1 <- nhanesA::nhanes(dbname1)
    names(dat1) <- gsub("DR[1-9]", "", names(dat1))
    keepers <- c("SEQN", "TKCAL", "TSFAT", "TALCO", "TSODI", 
                 "TMFAT", "TPFAT")
    dat1 <- dat1[, names(dat1) %in% keepers]
    dbname2 <- paste0(names(daychoices[2]), "TOT_", names(which(yearchoices == 
                                                                  year)))
    dat2 <- nhanesA::nhanes(dbname2)
    names(dat2) <- gsub("DR[1-9]", "", names(dat2))
    keepers <- c("SEQN", "TKCAL", "TSFAT", "TALCO", "TSODI", 
                 "TMFAT", "TPFAT")
    dat2 <- dat2[, names(dat2) %in% keepers]
    dat <- rbind(dat1, dat2)
    dat <- data.frame(apply(dat, 2, as.numeric))
    dat <- dat[!is.na(dat$TSFAT), ]
    dat <- stats::aggregate(. ~ SEQN, data = dat, FUN = "mean")
  }
  dat
}

diet <- get_diet('2015/2016', 'both')
hei_data <- hei(fped, diet, demo[, c("SEQN", 'SDDSRVYR')], verbose = T)

saveRDS(hei_data, file='./xpt/hei_diet.RDS')
