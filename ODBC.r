library("RODBC")
sqlHost <- "MSI\\POLOYAYA"
sqlDatabase <- "RevoTestDB"
sqlUser <- "George"
sqlPw <- "george123"


# Define SQL Server connection string ----------------
dsn <- sprintf("Driver=SQL Server;Server=%s;Database=%s;Uid=%s;Pwd=%s;",
               sqlHost, sqlDatabase, sqlUser, sqlPw)

channel <- odbcDriverConnect(dsn)


#### small Data Set ####
Start <- Sys.time()
  SqlData <- sqlQuery(channel,paste("select * from [RevoTestDB].[db_datareader].[AirlineDemoSmall] "))
  model.lm <- lm(ArrDelay ~ CRSDepTime + DayOfWeek - 1, SqlData)
  #system.time(model.lm <- lm(ArrDelay ~ CRSDepTime + DayOfWeek - 1, myData))
Sys.time() - Start
  
odbcClose(channel)

##################################################################################
library(RODBC)
sqlHost <- "MSI\\POLOYAYA"
sqlDatabase <- "Master" #"RevoTestDB"
sqlUser <-  ""          #"George"
sqlPw <- ""             #"george123"

# Define SQL Server connection string ----------------
dsn <- sprintf("Driver=SQL Server;Server=%s;Database=%s;Uid=%s;Pwd=%s;",
               sqlHost, sqlDatabase, sqlUser, sqlPw)

channel <- odbcDriverConnect(dsn)

#### Large Data Set ####
Start <- Sys.time()
  SqlData <- sqlQuery(channel,paste("select * from [AirlineLarge]"))
  model.lm <- lm(ArrDelay ~ CRSDepTime + DayOfWeek - 1, SqlData)
  #system.time(model.lm <- lm(ArrDelay ~ CRSDepTime + DayOfWeek - 1, myData))
Sys.time() - Start

odbcClose(channel)









