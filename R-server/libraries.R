
checkAndInstall <- function(mypkg){
   if (! is.element(mypkg, installed.packages()[,1])) install.packages(mypkg)
   library(mypkg)
  } 

options(repos = "https://cran.mirror.garr.it/CRAN/")

print("Loading libraries...")

#checkAndInstall("validate")
#checkAndInstall("validatetools")
#checkAndInstall("errorlocate")
#checkAndInstall("univOutl")
#checkAndInstall("simputation")
#checkAndInstall("VIM")
#checkAndInstall("rspa")
#checkAndInstall("varhandle")
checkAndInstall("RestRserve")
checkAndInstall("jsonlite")
checkAndInstall("data.table")
checkAndInstall("factoextra")
checkAndInstall("plyr")
checkAndInstall("dplyr")
checkAndInstall("ggplot2")


print("Loading libraries...ok ")