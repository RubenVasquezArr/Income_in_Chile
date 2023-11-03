# -------------------------------- Casen 2022 xgboost --------------------------------#

#This script purpose is apply a xgboost to the casen 2022 data.

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

library(mlr3verse)
library(data.table)
library(mlr3extralearners)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

names(casen)

#Adjust factor levels
casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]
casen[,migrant:=relevel(migrant, ref = "No migrant")]

#make logical variables instead of factors to comply requisites
casen[gender=="2. Mujer",is_female:= 1]
casen[gender=="1. Hombre",is_female:= 0]
casen[,is_female:= as.logical(is_female)]

casen[migrant=="Migrant",is_migrant:= 1]
casen[migrant=="No migrant",is_migrant:= 0]
casen[,is_migrant:= as.logical(is_migrant)]

#clean region names to create dummy variables for each one
casen[, est_region := gsub("[[:punct:]]", "", region)]
casen[, est_region := gsub(" ", "_", est_region)]
casen[, est_region := iconv(est_region, from = "UTF-8", to = "ASCII//TRANSLIT")]
casen[, est_region := tolower(est_region)]

#create dummy variables for each region
regions<-casen[,c("id","est_region")]
regions <- dcast(regions, id ~ est_region, value.var = "est_region", fill = 0, fun = function(x) 1)

# Select columns of interest

casen<-casen[,c("id",
                "study_years",
                "age",
                "is_female",
                "working_hours",
                "is_migrant",
                "salary_quantile")]

#merge with dummy variables
casen<-merge(casen,regions,by="id")
casen[,id:=NULL]

# Create a classification task
task = as_task_classif(casen,target = 'salary_quantile')

# Split the data into a training and test set
train_set = sample(task$row_ids, 0.67 * task$nrow)
test_set = setdiff(task$row_ids, train_set)

# Create a classification learner (xgboost)
learner = lrn("classif.xgboost")

# Train the learner 
learner$train(task, row_ids = train_set)
pred_train = learner$predict(task, row_ids=train_set)
pred_test = learner$predict(task, row_ids=test_set)

#measures of accuracy
measures <-msrs(c("classif.acc","time_train","time_predict"))

confusion<-pred_test$confusion
measures<-pred_test$score(measures, learner = learner)

# Calculate Mean Squared Error (MSE)
pred_test<-as.data.table(pred_test)
pred_test[,truth_numeric:=as.numeric(substr(as.character(truth),1, 1))]
pred_test[,response_numeric:=as.numeric(substr(as.character(response),1, 1))]

mse <- mean(pred_test[,(truth_numeric-response_numeric)^2])
mae<-mean(abs(pred_test[,(truth_numeric-response_numeric)]))

#saving results

cat(capture.output(confusion),"\n",
    capture.output(measures),"\n",
    paste("The MSE is: ",round(mse,digits = 2),sep = ""),
    paste("The MAE is: ",round(mae,digits = 2),sep = ""),
    sep="\n",
    file="src\\models\\results\\casen_2022_extreme_gradient_boosting_results.txt")

saveRDS(learner, 'src\\models\\results\\casen_2022_extreme_gradient_boosting_learner.rds')
