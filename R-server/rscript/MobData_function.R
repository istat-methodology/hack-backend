 
  
downloadDataFile <- function() {
  print("downloading data file....")
  return( download.file("https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv", FILE_Global_Mobility_Report))
  print("download ok")
  return("ok")
}

  