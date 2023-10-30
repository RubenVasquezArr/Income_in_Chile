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

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_for_modeling.csv",stringsAsFactors = T)

#-------- Initial exploration ####

names(casen)
#mincer equation

casen[,region:=relevel(region, ref = "Región Metropolitana de Santiago")]
casen[,rural_or_urban:=relevel(rural_or_urban, ref = "Urbano")]

casen[gender=="2. Mujer",is_female:= 1]
casen[gender=="1. Hombre",is_female:= 0]
casen[,is_female:= as.logical(is_female)]

casen[migrant=="Migrant",is_migrant:= 1]
casen[migrant=="No migrant",is_migrant:= 0]
casen[,is_migrant:= as.logical(is_migrant)]

casen[,migrant:=relevel(migrant, ref = "No migrant")]


casen[, est_region := gsub("[[:punct:]]", "", region)]
casen[, est_region := gsub(" ", "_", est_region)]
casen[, est_region := iconv(est_region, from = "UTF-8", to = "ASCII//TRANSLIT")]
casen[, est_region := tolower(est_region)]

regions<-casen[,c("id","est_region")]
regions <- dcast(regions, id ~ est_region, value.var = "est_region", fill = 0, fun = function(x) 1)


casen<-casen[,c(#"raw_salary",
  "id",
  "study_years",
  "age",
  "is_female",
  "working_hours",
  "is_migrant",
  "salary_quantile")]



casen<-merge(casen,regions,by="id")
casen[,id:=NULL]



task = as_task_classif(casen,target = 'salary_quantile')

train_set = sample(task$row_ids, 0.67 * task$nrow)
test_set = setdiff(task$row_ids, train_set)

learner = lrn("classif.xgboost")

learner$train(task, row_ids = train_set)
pred_train = learner$predict(task, row_ids=train_set)
pred_test = learner$predict(task, row_ids=test_set)

pred_train


measures <-msrs("classif.acc")

pred_test$confusion

pred_train$score(measures)
