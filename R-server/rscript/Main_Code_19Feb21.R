#### GOOGLE MOBILITY
#N.B. -- TRASFORMARE IN FUNZIONE. INPUT:
# 1) SE I DATI DI MOBILITA' SONO GIA' SCARICATI DB_STAT + SUBREGION
# 2) VICEVERSA REGION E SUBRIGION E SCAREICARE DATI CON MOBDATA

#install.packages("data.table")
library(data.table)
library(factoextra)
library(plyr) 
library(dplyr)
library(ggplot2)

basedir=setwd(".")

### 1 - CARICO I DATI E SALVO IL DB PULITO IN FORMATO CSV NELLA DIRECTORY SPECIFICATA
###     NEL PARAMETRO - RIGA 7
# Carico la source
source(paste(basedir,"MobData_function.R",sep="/"))
# Lancio la funzione
loadData()

### SUMMARY MOBILITY
# PARAMETER 
region     = "Italy" # Paese Europeo da Scaricare
# regione di interesse (Tuscany, Campania...) se missing scarica tutto
# N.B. i nomi sono in Inglese
subregion  = "Italy"  
# CARICO LA SOURCE
source(paste(basedir,"DescSummary_function.R",sep="/"))
# LANCIO LA FUNZIONE
descSummary(basedir,region,subregion)


# PLOT MOBILITY COMPONENTS
# CARICO LA SOURCE
source(paste(basedir,"PlotMobComp_function.R",sep="/"))
# LANCIO LA FUNZIONE
PlotMobComp(basedir,region,subregion)

# POLICY INDICATOR
# CARICO LA SOURCE
source(paste(basedir,"PolicyIndicator_function.R",sep="/"))
# LANCIO LA FUNZIONE
PolInd(basedir,region,subregion)


####################################################################################

#### DA VALIDARE...
# Modelli per i Bec
# Inserire Analisi per Bec comparativa rispetto al totale se a cavallo del
# trattamento c'è una composizione diversa del totale Import/Export
# Rispetto ad ITSA -> Provare come funziona su IMPORT e rispetto agli altri PAESI e altri PARTNER
# Provato ITALIA -MONDO, ITALIA BEC, MONDO-BEC

############# ANALISI IMPORT EXPORT - DEVE DIVENTARE UN'ALTRA FUNZIONE #############
# PARAMETERS SET
#scegliere 1='IMPORT', 0='EXPORT' ed importare il file corrispondente
flow<- 0 






#decido anno e mese di trattamento (123 = MARZO 2020)
year  = 2020 
month = 3    # marzo
treat <- which(db$year == 2020)[[1]] + month - 1

# SE C'E' UN DB CON SIGLE INTERNAZIONALI METTERE SEMPRE REGION E FARE DECODIFICA
# "AT" "BE" "BG" "CY" "CZ" "DE" "DK" "EE" "ES" "FI" "FR" "GB" "GR" "HR" 
# "HU" "IE" "IT" "LT" "LU" "LV" "MT" "NL" "PL" "PT" "RO" "SE" "SI" "SK"

# Vedere come fare tabella di raccordo con sigle.

country<-'IT' #selezionare la sigla del paese (prime due lettere in inglese)

partner<-"WO"  #selezionare il partner (WO=world,US=USA,CH=China)

if (flow==0) {
  db <- fread("C:/Users/Barbara/Documents/ISTAT/MEA/Hacketon/exp.csv", colClasses = list(numeric=4:5778))
  FLOW<-'EXPORT'
} else if (flow==1) {
  db <- fread("C:/Users/Barbara/Documents/ISTAT/MEA/Hacketon/imp.csv", colClasses = list(numeric=4:5778))
  FLOW<-'IMPORT'
} 

#################
# carico i nomi dei BEC 
bec<-c("FOOD AND BEVERAGES","INDUSTRIAL SUPPLIES","FUELS AND LUBRICANTS",
       "CAPITAL GOODS","TRANSPORT EQUIPMENT","CONSUMER GOODS","TOTAL")

#scelgo la variabile oggetto di studio
# totale = 7
# sottocategorie dette bec = (1,6)
VAR<-7

##########################################
##########################################.
#operazioni preliminari sui dati
# subset per paese e partner
a1 <- db[which(db$country_sh==country),]

a0<-a1[,c(1,2,3)]
a2 <- a1 %>% select(starts_with(partner))
aa <- cbind(a0,a2)

#aggrego BEC alla prima cifra
b1<-rowSums(aa[,4:7])
b2<-rowSums(aa[,8:9])
b3<-rowSums(aa[,10:12])
b4<-rowSums(aa[,13:14])
b5<-rowSums(aa[,15:18])
b6<-rowSums(aa[,19:21])
b <- as.data.frame(cbind(b1,b2,b3,b4,b5,b6))
colnames(b)<-paste(partner,1:6,sep="")
aa1 <- cbind(a0,b,aa[,23])

#subset colonna della var oggetto di studio
#ordino il dataset,divido per un milione 
#rimuovo i dataframe di appoggio
dati<-aa1[order(aa1$year),]
dati<-dati[,c(4:10)]/1000000
dati<-subset(dati,select=c(VAR))
colnames(dati)<-c("VAR")
dati<-dati[which(dati$VAR!=0),]
rm(a0,a1,a2,aa,aa1,b,b1,b2,b3,b4,b5,b6)
gc()

#lunghezza db
l<-length(dati$VAR)
