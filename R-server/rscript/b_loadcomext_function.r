

loadcomext <- function(flow){
  
  
  if (flow==2) {
    db <- fread(paste(basedirData,"exp.csv",sep="/"), colClasses = list(numeric=4:5778))
  } else if (flow==1) {
    db <- fread(paste(basedirData,"imp.csv",sep="/"), colClasses = list(numeric=4:5778))
  } 
  

  return(db)
  
}
