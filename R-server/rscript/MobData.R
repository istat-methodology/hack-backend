  # Sarebbe Ottimale se riuscissimo a Scaricare solo i dati che ci interessano senza scaricare tutto il 
  # DB ma per ora va bene
  Global_Mobility_Report<- fread("https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv")
  gmr<-subset(Global_Mobility_Report,country_region==region)
  gmr<-as.data.frame(gmr)
  gmr$sub_region<-ifelse(gmr$sub_region_1=="",region,gmr$sub_region_1)
  var<-c("Dates","Retail","Grocery_Pharmacy","Parks","Transit_Station","Workplaces","Residential")
  db_stat<-gmr[(gmr$sub_region==subregion),]
  db_stat<-db_stat[,8:14]
  db_stat[is.na(db_stat)]<-0
  colnames(db_stat)<-var
  ris<-list()
  
  # Elimino alcuni elementi tipo Global, gmr perchè non mi servono lascio solo il DB che mi serve
  rm(Global_Mobility_Report,gmr)