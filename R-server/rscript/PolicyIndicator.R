# Policy Indicator

######### BARBARA  ####################
PCAest <-prcomp(db_stat[,c(2:7)],scale=TRUE)

library(factoextra)
library(ggplot2)
# Results for Variables
res.var <- get_pca_var(PCAest)
print(res.var$coord)          # Coordinates
print(res.var$contrib)        # Contributions to the PCs
print(res.var$cos2)           # Quality of representation 

tab_res<-as.data.frame(res.var[c(1,4,3)])
tab_res<-tab_res[c(1,7,13)]
View(tab_res)
tab_var<-c("Coordinates","Contributions to the PCs","Quality of representation")
colnames(tab_res)<-tab_var

dev.new()
print(fviz_eig(PCAest))

dev.new()
print(fviz_pca_var(PCAest,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
) +   labs(title = paste(subregion,"Variables - PCA",sep=" ")))

PC1 <- PCAest$x[,'PC1']

dates <- db_stat[,1];

#dev.new()
#plot(dates,PC1,type="h",ylim=c((min(PC1,na.rm=TRUE)),(max(PC1,na.rm=TRUE))),xlab="",ylab="Policy Indicator -PC1")

minI = min(PC1);
maxI = max(PC1);

PolInd = (PC1-minI)/(maxI-minI)

dev.new()

smoothingSpline = smooth.spline(dates, PolInd, spar=0.35)

plot(dates,PolInd,type="h",ylim=c((min(PolInd,na.rm=TRUE)),(max(PolInd,na.rm=TRUE))),
     xlab="",ylab="Policy Indicator -PC1",col='gray',
     main=paste(subregion,"Policy Indicator",sep=" "))
legend("topleft", c("Policy Restriction Level"),
       lty = 1, col = c("black"), cex = 0.6)
lines(smoothingSpline,col="red",lwd=2)


db_stat$PolInd <- PolInd

library(zoo)
x <- as.POSIXct(db_stat$Dates,format="%Y-%m-%d")
mo <- strftime(x, "%m")
yr <- strftime(x, "%Y")
PolInd_M <- db_stat$PolInd
dd <- data.frame(mo, yr, PolInd_M)
dfM <- aggregate(PolInd_M ~ mo + yr, dd, FUN = mean)
dfM$Date <- as.yearmon(paste(dfM$yr, dfM$mo), "%Y %m")


dev.new()

smoothingSpline = smooth.spline(dfM$Date, dfM$PolInd_M, spar=0.35)

plot(dfM$Date,dfM$PolInd_M,type="h",ylim=c((min(dfM$PolInd_M,na.rm=TRUE)),(max(dfM$PolInd_M,na.rm=TRUE))),
     xlab="",ylab="Policy Indicator -PC1",col='gray',
     main=paste(subregion,"Monthly Policy Indicator",sep=" "))
legend("topleft", c("Policy Restriction Level"),
       lty = 1, col = c("black"), cex = 0.6)
lines(smoothingSpline,col="red",lwd=2)

rm(x,mo,yr,dd)



