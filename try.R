sqlConnString <- "Driver=SQL Server;Server=MSI\\POLOYAYA;
Database=RevoTestDB;Uid=George;Pwd=george123"

sqlFraudTable <- "ccFraudSmall"
sqlRowsPerRead = 5000

# Connect to DB
sqlFraudDS <- RxSqlServerData(connectionString = sqlConnString,
                              table = sqlFraudTable, rowsPerRead = sqlRowsPerRead)

# Load the Sample Data
ccFraudCsv <- file.path(rxGetOption("sampleDataDir"),
                        "ccFraudSmall.csv")
# Define data type
inTextData <- RxTextData(file = ccFraudCsv,
                         colClasses = c(
                           "custID" = "integer", "gender" = "integer", "state" = "integer",
                           "cardholder" = "integer", "balance" = "integer",
                           "numTrans" = "integer",
                           "numIntlTrans" = "integer", "creditLine" = "integer",
                           "fraudRisk" = "integer"))
# wirte to DB
rxDataStep(inData = inTextData, outFile = sqlFraudDS, overwrite = TRUE)

