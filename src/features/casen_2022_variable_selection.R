# -------------------------------- Casen 2022 processing --------------------------------#

#This script purpose is to filter and convert the raw data from casen 2022 survey.

#-------- Initial configuration ####

# Trigger the garbage collector
gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())

#------- Open libraries
#install.packages("data.table")
#install.packages("car")
#install.packages("caret")
#install.packages("corrplot")

library(data.table)
library(car)
library(caret)
library(corrplot)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_processed.csv",stringsAsFactors = T)

#-------- Initial exploration ####

#str(casen)
#head(casen)
#summary(casen)
#names(casen)

#for this study, it would be recomendable to only analize people who recieve an income, since that is the study variable 

casen<-casen[!is.na(raw_salary) &
                               raw_salary != 0,]

#there is also a very small amount of individuals who have NA as their study years. 

casen<-casen[!is.na(study_years ),]

#and some who reciebe an income, but family income is na

casen<-casen[!is.na(fmly_income ),]

#-------- Variables selection ####

#Identifying numeric variables wich are not ids,nor expansion factors

numeric_casen<- casen[ , .SD, .SDcols = is.numeric]

non_id_list<-which(!names(numeric_casen) %like% "id")
numeric_casen <- numeric_casen[ ,..non_id_list] 

numeric_casen[,expr:=NULL]

#there is people witout 

#Calculating Correlation
descrCor <- cor(numeric_casen,)

# Print correlation matrix and look at max correlation
print(descrCor)

corrplot(descrCor, order = "FPC", method = "color", type = "lower", tl.cex = 0.7, tl.col = rgb(0, 0, 0))

#this demostrates that study years have a huge impact in raw salary, 



kruskal.test()