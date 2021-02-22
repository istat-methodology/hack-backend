dev.new()
par(mar = rep(2, 4))
par(mfrow=c(3,2))
dbr<-db_stat
dbr[is.na(dbr)]<-0

for (i in 2:7)
{
  a<-dbr[,1]
  b<-dbr[,i]
  c<-data.frame(a,b)
  a<-c[,1]
  b<-c[,2]
  
  smoothingSpline = smooth.spline(a,b, spar=0.35)
  plot(a,b,type="h",xlab="Dates",
       main=paste(subregion,var[i],sep =" "))
  lines(smoothingSpline,col="red",lwd=2)
  abline(h=0)
  print(i)
}

rm(dbr)