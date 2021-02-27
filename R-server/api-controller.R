library("RestRserve")
library("jsonlite")
library("data.table")
library("factoextra")
library("plyr") 
library("dplyr")
library("ggplot2")

# Input che l'utente volendo puï¿½ impostare


basedir = ("./rscript")
basedirData=("./data")
FILE_Global_Mobility_Report=paste(basedirData,"Global_Mobility_Report.csv",sep="/")
FILE_DB_Mobility=paste(basedirData,"DB_GoogleMobility.csv",sep="/")
FILE_COUNTRY=paste(basedirData,"country.json",sep="/")

source(paste(basedir,"apps_functions.R",sep="/"))
source(paste(basedir,"MobData_function.R",sep="/"))
source(paste(basedir,"DescSummary_function.R",sep="/"))
# PLOT MOBILITY COMPONENTS
# CARICO LA SOURCE
source(paste(basedir,"PlotMobComp_function.R",sep="/"))
# POLICY INDICATOR
# CARICO LA SOURCE
source(paste(basedir,"PolicyIndicator_function.R",sep="/"))
 

##
## altri caricamenti fi funzioni
## source(".. ")
##
app = Application$new()
COUNTRIES<-loadCountries()
GMR<-loadData()
head(GMR)
 
app$add_get(
  path = "/load-data", 
  FUN = function(.req, .res) {
    downloadDataFile()
    GMR<-loadData()
    .res$set_body("Load data ok")
    .res$set_content_type("application/json")
  })

app$add_get(
  path = "/desc-summary", 
  FUN = function(.req, .res) {
    print("/desc-summary")
    stats<-descSummary(.req$get_param_query("region"),.req$get_param_query("subregion")) 
     
   .res$set_body(stats)
   
   .res$set_content_type("application/json")
  })

# PLOT MOBILITY COMPONENTS
# DA FARE CON L'OUTPUT
# Da questa funzione esce un oggetto contenente 6 data-frame uguali in ciascuno sono 
# contenuti 3 vettori: Date: le date (asse x), Value (i valori della serie da plottare come
# linee che partono dallo zero fino al punto indicato), Smooth(y di una linea rossa leggermente
# piï¿½ spessa) - I 6 grafici avranno i seguenti nomi:
# Frame 1: Region (parametro dinamico) Retail
# Frame 2: Region (parametro dinamico) Grocery and Pharmacy 
# Frame 3: Region (parametro dinamico) Parks
# Frame 4: Region (parametro dinamico) Transit Station 
# Frame 5: Region (parametro dinamico) Workplaces
# Frame 6: Region (parametro dinamico) Residential


app$add_get(
  path = "/mobility-components", 
  FUN = function(.req, .res) {
    print("/mobility-components")
    resp<-PlotMobComp(.req$get_param_query("region"),.req$get_param_query("subregion"))  
    print(resp)
    .res$set_body(resp)
    
    .res$set_content_type("application/json")
  })

#POLICY INDICATOR
# Da qui otteniamo un oggetto con 4 dataframe
# 1- PCAresult --> da rappresentare in una tabella (questi dati sono alla base del plot con
# le coordinate figura 1)
# 2 -  ExpVar --> Variance Explained da rappresentare con un Scree Plot: un istogramma
      #linea nera che unisce i punti centrali di ogni istogramma vedi figura 2
# 3 - DPolInd,MPolInd -> Indicatore di policy giornaliero e mensile da trattare come i
# dati del file precedente (componenti) - figure 3 e 4


app$add_get(
  path = "/policy-indicator", 
  FUN = function(.req, .res) {
    print("/policy-indicator")
    resp<-PolInd(.req$get_param_query("region"),.req$get_param_query("subregion"))  
    print(resp)
    .res$set_body(resp)
    
    .res$set_content_type("application/json")
  })


app$add_get(
  path = "/countries", 
  FUN = function(.req, .res) {
   resp<-countries(.req$get_param_query("country"),.req$get_param_query("name"))  
   .res$set_body(resp)
 
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
backend$start(app, http_port = 5000)

