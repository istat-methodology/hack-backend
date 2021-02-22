############## MAIN #######################

# MOBILITY PARAMETER 

#### GOOGLE MOBILITY
#N.B. -- TRASFORMARE IN FUNZIONE. INPUT:
# 1) SE I DATI DI MOBILITA' SONO GIA' SCARICATI DB_STAT + SUBREGION
# 2) VICEVERSA REGION E SUBRIGION E SCAREICARE DATI CON MOBDATA

#install.packages("data.table")
setwd("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\")

library(data.table)
library(factoextra)
library(data.table)
library(bit64)
#install.packages("tidyverse")
library(tidyverse)
library(readxl)
library(sandwich)
library(lmtest)
library(magrittr) 
library(dplyr)

region     = "Italy" # Paese Europeo da Scaricare
# regione di interesse (Tuscany, Campania...) se missing scarica tutto
# N.B. i nomi sono in Inglese
subregion  = "Italy"  

# CODES
# Dowload Data
debugSource("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\MobData.R")
# Table Descriptive Statistics
debugSource("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\DescSummary.R")
# Plot Mobility Components
source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\PlotMobComp.R")
# Policy Indicator
source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\PolicyIndicator.R")


####################################################################################

#### DA VALIDARE...
# Modelli per i Bec
# Inserire Analisi per Bec comparativa rispetto al totale se a cavallo del
# trattamento c'è una composizione diversa del totale Import/Export
# Rispetto ad ITSA -> Provare come funziona su IMPORT e rispetto agli altri PAESI e altri PARTNER
# Provato ITALIA -MONDO, ITALIA BEC, MONDO-BEC

############# ANALISI IMPORT EXPORT - DEVE DIVENTARE UN'ALTRA FUNZIONE #############

################# PARAMETERS SET
# Scegliere 1='IMPORT', 0='EXPORT' ed importare il file corrispondente
flow<- 0 

# SIGLE INTERNAZIONALI METTERE SEMPRE REGION E FARE DECODIFICA
# "AT" "BE" "BG" "CY" "CZ" "DE" "DK" "EE" "ES" "FI" "FR" "GB" "GR" "HR" 
# "HU" "IE" "IT" "LT" "LU" "LV" "MT" "NL" "PL" "PT" "RO" "SE" "SI" "SK"

country<-'IT' #selezionare la sigla del paese (prime due lettere in inglese)

partner<-"WO"  #selezionare il partner (WO=world,US=USA,CH=China)

#scelgo la variabile oggetto di studio totale = 7 sottocategorie bec = (1,6)
VAR<-7        

#decido anno e mese di trattamento (123 = MARZO 2020)
year  = 2020 
month = 3    # marzo

#######################################################################
if (flow==0) {
  db <- fread("D:\\hackathon_dati\\r-server\\exp.csv", colClasses = list(numeric=4:5778))
  FLOW<-'EXPORT'
} else if (flow==1) {
  db <- fread("D:\\hackathon_dati\\r-server\\imp.csv", colClasses = list(numeric=4:5778))
  FLOW<-'IMPORT'
} 

treat <- which(db$year == 2020)[[1]] + month - 1

# CODES
# INT TRADE Data
source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\IntData.R")
# Graph original data + seasonal adjusted series (yearly variation series)
source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\seriesGraph.R")
# Interrupted time series analysis
source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\itsa.r")

#statistiche sui bec
if (VAR<7) {
  source("C:\\Users\\ibuku\\ownCloud\\hackathon 2021\\r-server\\hackaton - bozza script r statistiche\\bec.r")
}

