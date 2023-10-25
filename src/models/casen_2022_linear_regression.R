# -------------------------------- Casen 2022 processing --------------------------------#

#This script purpose is to filter and convert the raw data from casen 2022 survey.

#-------- Initial configuration ####

# Trigger the garbage collector
gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())


options(scipen = 999)
#------- Open libraries


library(data.table)
library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(mlr3viz)
library(ggplot2)
library(ggplot2)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

names(casen)
#mincer equation

casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]
casen[,gender:=relevel(gender, ref = "1. Hombre")]
casen[,migrant:=relevel(migrant, ref = "No migrant")]

mincer<- lm(formula = log(raw_salary) ~ study_years + 
              age + 
              I(age^2),
            data = casen)


summary(mincer)



power_mincer<- lm(formula = log(raw_salary) ~ study_years +
                    age +
                    I(age^2) +
                    region+
                    gender+
                    working_hours+
                    migrant,
                  data = casen)

summary(power_mincer)

rmse<-sqrt(mean(power_mincer$residuals^2))
exp(rmse)

ggplot(casen, aes(x = raw_salary)) +
  geom_histogram(bins = 100) +
  scale_x_continuous(labels = scales::comma) +
  labs(x = "Salary (CLP)", y = "Count") +
  theme_minimal()
 

ggplot(power_mincer, aes(x = .fitted)) + geom_histogram()  

#this shows that the median error is more almos half of the whome median salary. the rmse being that high, also shows that there is a ig impact in a few outliers. finally, the sqr is high considering the variability explained

#this is the model that we will try to improve with machine learning, but there is a catch. since income is a continuous variable, we will need to use a regression model, but since we want to try different models, we will categorize the variable, and check the results with a classification model.

#for this, we have to get the qantile of the calculated salary for part of the set. 
predict(power_mincer, casen)

train_set = sample(1:nrow(casen), round(nrow(casen)*0.67))
test_set = setdiff(1:nrow(casen), train_set)


power_mincer<- lm(formula = log(raw_salary) ~ study_years +
                    age +
                    I(age^2) +
                    region+
                    gender+
                    working_hours+
                    migrant,
                  data = casen[train_set])

summary(power_mincer)


casen[test_set , predicted_salary:= exp(predict(power_mincer, casen[test_set]))]

#casen[,pred_quantile:=""]
casen[predicted_salary<=380000 ,pred_quantile:="1. 1st quintile"]
casen[predicted_salary>380000 & predicted_salary<=450000, pred_quantile:="2. 2nd quintile"]
casen[predicted_salary>450000 & predicted_salary<=600000, pred_quantile:="3. 3rd quintile"]
casen[predicted_salary>600000 & predicted_salary<=1000000,pred_quantile:="4. 4th quintile"]
casen[predicted_salary>1000000 ,pred_quantile:= "5. 5th quintile"]
#casen[is.na(predicted_salary)| raw_salary<=0,pred_quantile:="0. No salary"]

casen[,pred_quantile:=as.factor(pred_quantile)]

summary(casen[test_set,pred_quantile])
summary(casen[test_set,salary_quantile])


example <- confusionMatrix(data=casen[test_set,pred_quantile], reference = casen[test_set,salary_quantile])

#Display results 
example

