#### getData ####
library(RevoScaleR)
sampleDataDir <- rxGetOption("sampleDataDir")
inputFile <- file.path(sampleDataDir, "AirlineDemoSmall.csv")
airDS <- rxImport(inData = inputFile, outFile = "ADS.xdf",
                  missingValueString = "M", stringsAsFactors = TRUE, overwrite = TRUE)
head(airDS)
dim(airDS)
object.size(airDS)

myData <-  rxReadXdf(airDS)
day.names <- paste0(c("Mon", "Tues", "Wednes", "Thurs", "Fri", "Satur", "Sun"),
                    "day")
levels(myData$DayOfWeek) <- day.names

## write New XDF ##
rxDataStep(inData = myData, outFile = "ADSNew.xdf", overwrite = TRUE)


##### write data to DB ####
sqlHost <- "MSI\\POLOYAYA"
sqlDatabase <- "RevoTestDB"
sqlUser <- "George"
sqlPw <- "george123"


# Define SQL Server connection string ----------------
con <- sprintf("Driver=SQL Server;Server=%s;Database=%s;Uid=%s;Pwd=%s",
               sqlHost, sqlDatabase, sqlUser, sqlPw)

sqlFraudTable <- "AirlineDemoSmall"
sqlRowsPerRead = 10000

# Connect to DB
sqlFraudDS <- RxSqlServerData(connectionString = con,
                              table = sqlFraudTable, 
                              colInfo = list(ArrDelay = list(type = "integer"),
                                             DayOfWeek = list(type = "factor", levels = day.names) 
                              )
                              , rowsPerRead = sqlRowsPerRead)

rxDataStep(inData = "ADSNew.xdf", outFile = sqlFraudDS, overwrite = TRUE)


### Use RevoScaleR RxInSqlServer compute context ####

# Define data object, including database table -------
airData <- RxSqlServerData(
  connectionString = con, 
  table = "AirlineDemoSmall",
  colInfo = list(ArrDelay = list(type = "integer"),
                 DayOfWeek = list(type = "factor", levels = day.names) 
  )
)

head(airData)

# Define compute context ，Becareful-----------------------------
rxSetComputeContext(
  RxInSqlServer(connectionString = con, 
                autoCleanup = FALSE, 
                consoleOutput = TRUE
  ) 
) 

# Perform analysis inside database -------------------

model.rxLinMod <- rxLinMod(ArrDelay ~ CRSDepTime + DayOfWeek - 1, airData)
summary(model.rxLinMod)

library(coefplot)
coefplot(model.rxLinMod, title = "Linear model using rxLinMod()")




