
## Machine learning Packages

library(caret)
library(randomForest)
## Notes for using randomForest
## rfmodel <- randomForest(trainDataFiltered[-1], trainDataFiltered$Arr_Del15, proximity = TRUE , importance = TRUE)
## trainDataFiltered[-1] removes the dependent variable from the data set
## trainDataFiltered$Arr_Del15 = the dependent variable
## rfValidation <- predict(rfmodel , testDataFiltered)
## rfConMat <- confusionMatrix(rfvalidation , testDataFiltered[,"ARR_DEL15"])
