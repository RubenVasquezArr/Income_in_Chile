# -------------------------------- Casen 2022 linear regression --------------------------------#

#This script purpose is apply a linear regression to the casen 2022 data.

#-------- Initial configuration ####

# Trigger the garbage collector
gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())

# Set options
options(scipen = 999)

#set seed for reproducibility
set.seed(14011994)

#------- Open libraries

library(data.table)
library(ggplot2)
library(caret)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

names(casen)

#Adjust factor levels
casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]
casen[,gender:=relevel(gender, ref = "1. Hombre")]
casen[,migrant:=relevel(migrant, ref = "No migrant")]


#initial mincer equation
mincer<- lm(formula = log(raw_salary) ~ study_years + 
              age + 
              I(age^2),
            data = casen)


summary(mincer)
mae<-mean(abs(mincer$residuals))
mean_log_salary<-mean(log(casen$raw_salary))
(exp(mean_log_salary+mae)-exp(mean_log_salary-mae))/2

#this shows that the model explains 0.27 of the variability, and that the mae is 0.4, which roufly translates to 223,458 CLP. this is a lot considering that the median salary is 500,000. this means that the model is not good enough, and that we need to add more variables.

power_mincer<- lm(formula = log(raw_salary) ~ study_years +
                    age +
                    I(age^2) +
                    region+
                    gender+
                    working_hours+
                    migrant,
                  data = casen)

summary(power_mincer)
mae<-mean(abs(power_mincer$residuals))
mean_log_salary<-mean(log(casen$raw_salary))
(exp(mean_log_salary+mae)-exp(mean_log_salary-mae))/2

#this show an improvement, but not a lot. the model explains 0.39 of the variability, and the mae is 0.38, which roufly translates to 204,215 CLP. this is a lot considering that the median salary is 500000. this means that the model is not good enough, and that we need to add more variables.

rmse<-sqrt(mean(power_mincer$residuals^2))
exp(rmse)
(exp(mean_log_salary+rmse)-exp(mean_log_salary-rmse))/2


#this shows that the median error is more almos half of the whome median salary. the rmse being that high, also shows that there is a big impact in a few outliers.

#this is the model that we will try to improve with machine learning, but there is a catch. From previous experiences, income predictions tend to overfit, due to the skeweness, outliers and variables used for the task. this is why the income was categorized in quintiles, and the models were trained to predict the quintile, instead of the income. for regression models, after the prediction, the quintile will be calculated.

# Split the data into a training and test set
train_set = sample(1:nrow(casen), round(nrow(casen)*0.67))
test_set = setdiff(1:nrow(casen), train_set)

# Train the model with a time measure
start_time <- Sys.time()
power_mincer<- lm(formula = log(raw_salary) ~ study_years +
                    age +
                    I(age^2) +
                    region+
                    gender+
                    working_hours+
                    migrant,
                  data = casen[train_set])
end_time <- Sys.time()
time_train<-as.numeric(end_time-start_time)

summary(power_mincer)

# Predict the test set with a time measure
start_time <- Sys.time()
casen[test_set , predicted_salary:= exp(predict(power_mincer, casen[test_set]))]
end_time <- Sys.time()
time_predict<-as.numeric(end_time-start_time)

# Calculate the predicted quintile
casen[predicted_salary<=380000 ,pred_quantile:="1. 1st quintile"]
casen[predicted_salary>380000 & predicted_salary<=450000, pred_quantile:="2. 2nd quintile"]
casen[predicted_salary>450000 & predicted_salary<=600000, pred_quantile:="3. 3rd quintile"]
casen[predicted_salary>600000 & predicted_salary<=1000000,pred_quantile:="4. 4th quintile"]
casen[predicted_salary>1000000 ,pred_quantile:= "5. 5th quintile"]
casen[,pred_quantile:=as.factor(pred_quantile)]

# Measures of accuracy
confusion <- confusionMatrix(data=casen[test_set,pred_quantile],
                           reference = casen[test_set,salary_quantile])
Accuracy<-as.numeric(confusion$overall["Accuracy"])
confusion<-confusion[2]$table

# Calculate Mean Squared Error (MSE)
casen[test_set,truth_numeric:=as.numeric(substr(as.character(salary_quantile),1, 1))]
casen[test_set,response_numeric:=as.numeric(substr(as.character(pred_quantile),1, 1))]

mse <- mean(casen[test_set,(truth_numeric-response_numeric)^2])
mae<-mean(abs(casen[test_set,(truth_numeric-response_numeric)]))

measures <- c("classif.acc"=Accuracy,
              "time_train"=time_train,
              "time_predict"=time_predict)

#saving results

cat(capture.output(confusion),"\n",
    capture.output(measures),"\n",
    paste("The MSE is: ",round(mse,digits = 2),sep = ""),
    paste("The MAE is: ",round(mae,digits = 2),sep = ""),
    sep="\n",
    file="src\\models\\results\\casen_2022_linear_regression_results.txt")

saveRDS(power_mincer, 'src\\models\\results\\casen_2022_linear_regression_lm.rds')

