
ris<-list()

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
View(stats)
rm(ris)