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
# install.packages("ggplot2")

library(data.table)
library(car)
library(caret)
library(corrplot)
library(ggplot2)

#-------- Open data ####

casen<-fread("data\\processed\\Casen_2022_processed.csv",stringsAsFactors = T)

#-------- Initial exploration ####

#str(casen)
#head(casen)
#summary(casen)
names(casen)

#for this study, it would be recomendable to only analize people who recieve an income, since that is the study variable 

casen<-casen[!is.na(raw_salary) &
                               raw_salary > 0,]

#there is also a very small amount of individuals who have NA as their study years. 

casen<-casen[!is.na(study_years ),]

#fix migrant variable

casen[migrant=="2. Chile y otro país"|
        migrant=="1. Chile (exclusivamente)" ,migrant:="No migrant"]

casen[migrant=="3. Otro país (extranjeros)",migrant:="Migrant"]

casen[,migrant:=as.factor(as.character(migrant))]
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

corrplot(descrCor, order = "FPC", method = "color", tl.cex = 0.7, tl.col = rgb(0, 0, 0))

#this demonstrates that study years have a huge impact in raw salary, and a very weak correlation with family members and age. working hours may be an interesting variable.
#an important note is that age is not correlated with income, but it is with study years, therefore some models could use it, such as kmeans or neural network. also, to comply with literature of mincer equation, we could use it as a proxy for experience.

#now for categorical columns

#region

kruskal.test(raw_salary ~ region, data = casen)

ggplot(casen, aes(x=raw_salary, y=region )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#rural_or_urban

kruskal.test(raw_salary ~ rural_or_urban, data = casen)

ggplot(casen, aes(x=raw_salary, y=rural_or_urban )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#gender

kruskal.test(raw_salary ~ gender, data = casen)

ggplot(casen, aes(x=raw_salary, y=gender )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#sector_quality

kruskal.test(raw_salary ~ sector_quality, data = casen)

ggplot(casen, aes(x=raw_salary, y=sector_quality )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance. Chile is a very segregated country, therefore the quality of the neibourhud is not so independent. since it is an observation of the surroundigns and not of the income itself, we could will it as well.

#study_field

kruskal.test(raw_salary ~ study_field, data = casen)

ggplot(casen, aes(x=raw_salary, y=study_field )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#business_size

kruskal.test(raw_salary ~ business_size, data = casen)

ggplot(casen, aes(x=raw_salary, y=business_size )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#migrant

kruskal.test(raw_salary ~ migrant, data = casen)

ggplot(casen, aes(x=raw_salary, y=migrant )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#indgn_comunity

kruskal.test(raw_salary ~ indgn_comunity, data = casen)

ggplot(casen, aes(x=raw_salary, y=indgn_comunity )) + 
  geom_boxplot()+ xlim( 0,2000000)

#there is a powerful significance and variance

#Concluded the variables study, we only are going to save these for the modeling part


casen<- casen[,c("id_indv",
                 "region",
                 "rural_or_urban",
                 "age",
                 "gender",
                 "sector_quality",
                 "study_years",
                 "study_field",
                 "working_hours",
                 "business_size",
                 "raw_salary",
                 "migrant")]

#saving

fwrite(casen,"data\\processed\\Casen_2022_for_modeling.csv")