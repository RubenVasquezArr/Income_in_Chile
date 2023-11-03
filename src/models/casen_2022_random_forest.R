# -------------------------------- Casen 2022 random forest --------------------------------#

#This script purpose is apply a random forest model to the casen 2022 data.

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
library(ranger)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

#names(casen)

#Adjust factor levels

casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]
casen[,gender:=relevel(gender, ref = "1. Hombre")]
casen[,migrant:=relevel(migrant, ref = "No migrant")]

# Select columns of interest

casen<-casen[,c("study_years",
                "age",
                "region",
                "gender",
                "working_hours",
                "migrant",
                "salary_quantile")]


# Create a classification task
task = as_task_classif(casen,target = 'salary_quantile')

# Split the data into a training and test set
train_set = sample(task$row_ids, 0.67 * task$nrow)
test_set = setdiff(task$row_ids, train_set)

# Create a classification learner (Random Forest)
learner = lrn("classif.ranger", importance = "impurity")

# Train the learner 
learner$train(task, row_ids = train_set)
pred_train = learner$predict(task, row_ids=train_set)
pred_test = learner$predict(task, row_ids=test_set)


# Measures of accuracy
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
    file="src\\models\\results\\casen_2022_random_forest_results.txt")

saveRDS(learner, 'src\\models\\results\\casen_2022_random_forest_learner.rds')
