################################################################
#plot dei BEC percetuale sul totale del flusso##################
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
dati_b<-aa1[order(aa1$year),]
dati_b<-dati_b[,c(4:10)]/1000000
dati_b<-dati_b[which(dati_b[,1]!=0),]
rm(a0,a1,a2,aa,aa1,b,b1,b2,b3,b4,b5,b6)

dati_b$p1<-dati_b[,1]/dati_b[,7]*100
dati_b$p2<-dati_b[,2]/dati_b[,7]*100
dati_b$p3<-dati_b[,3]/dati_b[,7]*100
dati_b$p4<-dati_b[,4]/dati_b[,7]*100
dati_b$p5<-dati_b[,5]/dati_b[,7]*100
dati_b$p6<-dati_b[,6]/dati_b[,7]*100

#dev.off()
dev.new()
par(mar = rep(2, 4))
par(mfrow=c(3,2))
d<-as.data.frame(dati_b[,c(8:13)])


for (i in 1:6)
{
  a<-c(1:l)
  b<-d[,i]
  c<-data.frame(a,b)
  a<-c[,1]
  b<-c[,2]
  
  plot(a,b,ylab=flow, xlab="Time", 
       main = paste(country,"-",partner,",",bec[i],", %tot", sep =" "))
  points(b,cex=0.9,col=3)
  abline(v=treat-1, lty=3)
  #smoothingSpline = smooth.spline(a,b, spar=0.35)
  #lines(smoothingSpline,col="red",lwd=2)
  print(i)
}

