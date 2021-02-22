
ris<-list()


descSummary <- function( region, subregion) {
   print("1111")
 head(Global_Mobility_Report)
  print("222")
  gmr<-subset(Global_Mobility_Report,country_region==region)
  gmr<-as.data.frame(gmr)
  gmr$sub_region<-ifelse(gmr$sub_region_1=="",region,gmr$sub_region_1)
  var<-c("Dates","Retail","Grocery_Pharmacy","Parks","Transit_Station","Workplaces","Residential")
  db_stat<-gmr[(gmr$sub_region==subregion),]
  db_stat<-db_stat[,8:14]
  db_stat[is.na(db_stat)]<-0
  colnames(db_stat)<-var
  ris<-list()
  print("bb")
 
for (i in 3:7)
{
  min<-round(min(db_stat[,i]),1)
  q1<-round(quantile((db_stat[,i]),0.25),1)
  med<-round(median(db_stat[,i]),1)
  avg<-round(mean(db_stat[,i]),1)
  q3<-round(quantile((db_stat[,i]),0.75),1)
  max<-round(max(db_stat[,i]),1)
  
  ris[[i-1]]<-data.frame(min,q1,med,avg,q3,max)
  print(i)
}

stats<-do.call("rbind", ris)
stats<-t(stats)
colnames(stats)<-paste(subregion, var[3:7],sep =" ")
#View(stats)
rm(ris)

return(stats)
  }
  