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
#install.packages("remotes")
#remotes::install_github("mlr-org/mlr3extralearners@*release")
library(mlr3verse)

library(data.table)
library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(mlr3viz)
library(ggplot2)
library(ggplot2)
library(mlr3extralearners)
library(mlr3learners)
library(ranger)
library(xgboost)
#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

names(casen)
#mincer equation

casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]
casen[,gender:=relevel(gender, ref = "1. Hombre")]
casen[,migrant:=relevel(migrant, ref = "No migrant")]

#

casen<-casen[,c(#"raw_salary",
  "study_years",
  "age",
  "region",
  "gender",
  "working_hours",
  "migrant",
  "salary_quantile")]

casen[,study_years:=as.numeric(study_years)]
casen[,age:=as.numeric(age)]
casen[,working_hours:=as.numeric(working_hours)]


task = as_task_classif(casen,target = 'salary_quantile')

train_set = sample(task$row_ids, 0.67 * task$nrow)
test_set = setdiff(task$row_ids, train_set)

learner = lrn("classif.nnet")
learner$train(task, row_ids = train_set)
pred_train = learner$predict(task, row_ids=train_set)
pred_test = learner$predict(task, row_ids=test_set)

pred_train


measures <-msrs("classif.acc")

pred_test$confusion

#measures = msrs(c('regr.rsq'))
pred_train$score(measures)



pred_test

pred_test$score(measures)
mean(casen$raw_salary)

