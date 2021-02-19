library(RestRserve)
library(jsonlite)
#source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\MobData_function.R")
#source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\DescSummary_function.R")
##
## altri caricamenti fi funzioni
## source(".. ")
## 
app = Application$new()
 
 
app$add_get(
  path = "/load-data", 
  FUN = function(.req, .res) {
    .res$set_body("loadData()")
    .res$set_content_type("text/plain")
  })

app$add_get(
  path = "/desc-summary", 
  FUN = function(.req, .res) {
 
    
   .res$set_body("descSummary(.req$get_param_query(\"region\"),.req$get_param_query(\"subregion\"))")

   .res$set_content_type("text/plain")
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
backend$start(app, http_port = 5500)

