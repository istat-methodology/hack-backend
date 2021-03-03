################################################
#grafici serie tendenziali e serie originale

sa<-function(flow,VAR,country,partner){

  db<-loadcomext(flow,VAR,country,partner)
  #decido anno e mese di trattamento (123 = MARZO 2020)
  year  = 2020 
  month = 3    # marzo
  treat <- which(db$year == 2020)[[1]] + month - 1
  ################################################################
  strdate = paste("01",paste(db$month[1],db$year[1],sep="/"),sep="/")
  enddate = paste("01",paste(db$month[length(db$month)],db$year[length(db$year)],sep="/"),sep="/")

  date = seq.Date(from =as.Date(strdate, "%d/%m/%Y"), 
                  to=as.Date(enddate, "%d/%m/%Y"),by="month")

  #lunghezza db
  l<-length(dati$VAR)
    
  #### calcolo i tendenziali
  dati$tend<-dati$VAR
  for (i in 13:l)
  {
    dati$tend[i]<-dati$VAR[i]-dati$VAR[i-12]
  }
  dati$tend[c(1:12)]<-NA

  dfor   <- data.frame(date[4:length(date)],dati$VAR)
  dftend <- data.frame(date[4:length(date)],dati$tend)

  tp1 ="scatter chart"
  tp2 = "line"

  return(list(dfor,dftend,tp1,tp2))
}