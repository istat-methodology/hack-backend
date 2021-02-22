library(RestRserve)
library(jsonlite)
# Input che l'utente volendo pu� impostare

#basedir=("C:\\Users\\Barbara\\Documents\\ISTAT\\MEA\\Hacketon\\R-Functions\\Francesco Amato")

basedir=("./rscript")
basedirData=("./data")
FILE_Global_Mobility_Report=paste(basedirData,"Global_Mobility_Report.csv",sep="/")
source(paste(basedir,"MobData_function.R",sep="/"))
source(paste(basedir,"DescSummary_function.R",sep="/"))



# DIRECTORY FRANCESCO 
#source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\MobData_function.R")
#source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\DescSummary_function.R")


##
## altri caricamenti fi funzioni
## source(".. ")
##
app = Application$new()
Global_Mobility_Report<-NULL
 
print("loading data file....")
if( !file.exists(FILE_Global_Mobility_Report)) {
  downloadDataFile()
}
Global_Mobility_Report<- read.csv(FILE_Global_Mobility_Report) 
  
print("data file loaded ok")
head(Global_Mobility_Report)
 

  
app$add_get(
  path = "/load-data", 
  FUN = function(.req, .res) {
    .res$set_body(downloadDataFile())
    .res$set_content_type("application/json")
  })

app$add_get(
  path = "/desc-summary", 
  FUN = function(.req, .res) {
    print("/desc-summary")
    resp<-descSummary(.req$get_param_query("region"),.req$get_param_query("subregion"))  
    print(resp)
   .res$set_body(resp)
   
   .res$set_content_type("application/json")
  })


##
## esempio funzionamento RestRserve
##
app$add_get(
  path = "/health", 
  FUN = function(.req, .res) {
    .res$set_body("OK")
  })

app$add_post(
  path = "/addone", 
  FUN = function(.req, .res) {
    result = list(x = .req$body$x + 1L)
    .res$set_content_type("application/json")
    .res$set_body(result)
  })


backend = BackendRserve$new()
backend$start(app, http_port = 5600)

