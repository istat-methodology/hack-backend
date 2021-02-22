######### ITSA ################################
# modello base y=t+d+td con dati tendenziali e 1 lag
# modello y=t+d+td+polind+tpolind con dati tendenziali e 1 lag
###############################################

###PRIMA PARTE, GRAFICI PER TIMELAPSE
#CARICO I DATI DEL POLICY INDICATOR
#polind ha dati piu recenti, 
#lo allineo e aggiungo al tempo del dataset dati

dfM$time<-c(122:(121+length(dfM$PolInd_M)))
dfM<-dfM[which(dfM$time<=l),]
dati$polind<-c(rep(0,(l-length(dfM$PolInd_M))),dfM$PolInd_M)
dati$polind[c(1:12)]<-NA

#### calcolo i valori della serie tendenziale
dati$tend<-dati$VAR
for (i in 13:l)
{
  dati$tend[i]<-dati$VAR[i]-dati$VAR[i-12]
}
dati$tend[c(1:12)]<-NA

#creo trend lineare che inizia con zero e arriva a t-1, partendo dalla 13a osservazione
dati$t<-NA
dati$t[13:l]<-c(0:(l-13))

#creo dummy trattamento partendo dalla 13a
#slittando treat di 12 osservazioni meno 1 per tenere conto del lag
dati$d<-c(rep(NA,12),c(rep(0,(l-12))))
dati$d<-ifelse(dati$t>=treat-13,1,0)

#interazioni
dati$td<-c(rep(0,treat),c(1:(l-treat)))
dati$td[c(1:12)]<-NA
dati$tpolind<-dati$td*dati$polind
dati$tpolind[c(1:12)]<-NA


############# GRAFICO STATICO EFFETTO GENERALE ED EFFETTO POLICY INDICATOR

#modellI itsa  con e senza polind
lm_tend<-lm(tend~t+d+td,data=dati)
#summary(lm_tend)
lm_tend_tp<-lm(tend~t+d+td+polind+tpolind,data=dati)
#lm_tend_tp<-lm(tend~t+d+td+polind,data=dati)
#summary(lm_tend_tp)

#correggo standard error per autocorrelazione a un lag
lm_tend_corr<-coeftest(lm_tend,vcov=NeweyWest(lm_tend,lag = 1, prewhite = 0, adjust = TRUE, verbose=T))
lm_tend_corr
lm_tend_tp_corr<-coeftest(lm_tend_tp,vcov=NeweyWest(lm_tend_tp,lag = 1, prewhite = 0, adjust = TRUE, verbose=T))
lm_tend_tp_corr

# We generate predicted values based on the model in order to create a plot
pred <- predict(lm_tend,type="response",dati)
dati$pred<-pred
pred_tp <- predict(lm_tend_tp,type="response",dati)
dati$pred_tp<-pred_tp
par(1,1)
dev.new()
plot(dati$tend,type="n",ylab=FLOW, xlab="Time", xlim = c(l-50,l),
     main = paste(FLOW,":",country,"-",partner,";",bec[VAR],"(mln. euro)",sep =" "))
points(dati$tend,cex=0.7)
abline(v=treat-1, lty=3)
lines(pred,col=3)
lines(pred_tp,col=2)

# generate predictions under the counterfactual scenario and add it to the plot
dati$d<-0
dati$t<-c(1:l)
dati$td<-0
dati$polind<-0
dati$tpolind<-0
pred_tp_c<- predict(lm_tend_tp,dati,type="response")
dati$pred_tp_c<-pred_tp_c
lines(dati$t,pred_tp_c,col=2,lty=2)

#per ritornare ai dati di partenza
dati$t<-NA
dati$t[13:l]<-c(0:(l-13))
dati$d<-c(rep(NA,12),c(rep(0,(l-12))))
dati$d<-ifelse(dati$t>=treat-13,1,0)
dati$td<-c(rep(0,treat),c(1:(l-treat)))
dati$td[c(1:12)]<-NA
dati$polind<-c(rep(0,(l-length(dfM$PolInd_M))),dfM$PolInd_M)
dati$polind[c(1:12)]<-NA
dati$tpolind<-dati$td*dati$polind
dati$tpolind[c(1:12)]<-NA

#################################################################à
####### script per grafici timelapse
## più tabella risultati stima effetti
# più tabella risultati coefficienti dei modelli (no output, serve a noi)

#numero di grafici=mesi post trattamento

n<-l-treat
#dev.off()
dev.new()
par(mar = rep(2, 4))
par(mfrow=c(4,2))


ris<-list()
beta_tpolind<-list()
for (i in 1:n)
{
  dd<-subset(dati,select=c(t,d,td,tend,polind,tpolind))
  h<-treat+i
  d<-dd[c(1:h),]
  a<-c(1:h)
  b<-d[,4]
  c<-data.frame(a,b)
  a<-c[,1]
  b<-c[,2]
  
  lm_tend_tp<-lm(tend~t+d+td+polind+tpolind,data=d)
  lm_tend<-lm(tend~t+d+td,data=d)
  
  lm_tend_tp_corr<-coeftest(lm_tend_tp,vcov=NeweyWest(lm_tend_tp,lag = 1, prewhite = 0, adjust = TRUE, verbose=T))
  
  beta_tpolind[[i]]<-lm_tend_tp_corr
  
  pred_tp <- predict(lm_tend_tp,type="response",d)
  
  plot(a,b,type="n",ylab=FLOW, xlab="Time", xlim = c(l-50,l),
       main = paste(country,"-",partner,"@ T +",i,";",bec[VAR],"(mln. euro)",sep =" "))
  points(b,cex=1.5, col=35)
  abline(v=treat-1, lty=3)
  lines(pred_tp,col=2)
  
  # generate predictions under the counterfactual scenario and add it to the plot
  d$d<-0
  d$t<-c(1:h)
  d$td<-0
  d$polind<-0
  d$tpolind<-0
  pred_tp_c<- predict(lm_tend_tp,d,type="response")
  lines(d$t,pred_tp_c,col=2,lty=2)
  
  ## stats
  stat_tend<-round(dati$tend[h],0)
  stat_cong<-round(dati$VAR[h]-dati$VAR[h-1],0)
  #avg_covid_eff<-round(lm_tend$coefficients[3],0)+round(lm_tend$coefficients[1],0)
  #avg_covid_eff_perc<-((round(lm_tend_tp$coefficients[1],0)+(round(lm_tend_tp$coefficients[3],0)
  #                        +round(lm_tend_tp$coefficients[4],0))))/(-19833.75)*100
  #avg_polind_perc<-((round(lm_tend_tp$coefficients[5],0)
  #                   +round(lm_tend_tp$coefficients[6],0)))/(-19833.75)*100
  
  ris[[i]]<-data.frame(stat_tend,stat_cong,0,0,0)
  print(i)
}

stats_tpolind <-do.call("rbind", ris)
stats_tpolind<-t(stats_tpolind)
var<-c("Yearly variation","Monthly variation","Stat1",
       "Stat2","Stat3")
rownames(stats_tpolind)<-var
colnames(stats_tpolind)<-paste("T+",1:n,sep="")
View(stats_tpolind)
rm(ris)
beta_tpolind <-do.call("rbind", beta_tpolind)
beta_tpolind[,4]<-round(beta_tpolind[,4],digits = 3)
View(beta_tpolind)
