#### getData ####
library(RevoScaleR)
myData <-  rxReadXdf("D:/Download/AirOnTime2012.xdf")
day.names <- paste0(c("Mon", "Tues", "Wednes", "Thurs", "Fri", "Satur", "Sun"),
                    "day")
levels(myData$DayOfWeek) <- day.names
myDat <- myData[1:1000000,c("ArrDelay","CRSDepTime","DayOfWeek")]
head(myDat)
dim(myDat)
##### write data to DB ####
sqlHost <- "MSI\\POLOYAYA"
sqlDatabase <- "Master" #"RevoTestDB"
sqlUser <-  ""          #"George"
sqlPw <- ""             #"george123"


# Define SQL Server connection string ----------------
con <- sprintf("Driver=SQL Server;Server=%s;Database=%s;Uid=%s;Pwd=%s",
               sqlHost, sqlDatabase, sqlUser, sqlPw)

sqlRowsPerRead = 200000

### Use RevoScaleR RxInSqlServer compute context ####

# Define data object, including database table -------
airData <- RxSqlServerData(
  connectionString = con, 
  table = "Airline",
  colInfo = list(ArrDelay = list(type = "integer"),
                 DayOfWeek = list(type = "factor", levels = day.names) 
  ), rowsPerRead = sqlRowsPerRead
)

## wirte to DB
rxDataStep(inData = myDat, outFile = airData, overwrite = TRUE)

model.rxLinMod <- rxLinMod(ArrDelay ~ CRSDepTime + DayOfWeek - 1, airData)

head(airData)

# Define compute context ，Becareful-----------------------------

rxGetComputeContext() 

# rxSetComputeContext(
#   RxInSqlServer(connectionString = con, 
#                 autoCleanup = FALSE, 
#                 consoleOutput = TRUE
#   ) 
# ) 


# Perform analysis inside database -------------------
# debug(rxLinMod)
for(i in 1:100){
  model.rxLinMod <- rxLinMod(ArrDelay ~ CRSDepTime + DayOfWeek - 1, airData)
}

summary(model.rxLinMod)

library(coefplot)
coefplot(model.rxLinMod, title = "Linear model using rxLinMod()")




