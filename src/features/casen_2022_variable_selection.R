# -------------------------------- Casen 2022 variable selection --------------------------------#

#This script purpose is to select and prepare the variables for the modeling part.

#-------- Initial configuration ####

# Trigger the garbage collector
gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())

#------- Open libraries

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

#-------- transformation ####


#for this study, it would be recommendable to only consider people who receive an income.

casen<-casen[!is.na(raw_salary) &
                               raw_salary > 0,]

#there is also a very small amount of individuals who have NA as their study years. 

casen<-casen[!is.na(study_years ),]

#fix migrant variable

casen[migrant=="2. Chile y otro país"|
        migrant=="1. Chile (exclusivamente)" ,migrant:="No migrant"]

casen[migrant=="3. Otro país (extranjeros)",migrant:="Migrant"]

casen[,migrant:=as.factor(as.character(migrant))]

#fix id too long

casen[,id:=1:nrow(casen)]

#quantiles

casen[,quantile:=""]

casen[raw_salary<=380000 ,salary_quantile:="1. 1st quintile"]
casen[raw_salary>380000 & raw_salary<=450000, salary_quantile:="2. 2nd quintile"]
casen[raw_salary>450000 & raw_salary<=600000, salary_quantile:="3. 3rd quintile"]
casen[raw_salary>600000 & raw_salary<=1000000,salary_quantile:="4. 4th quintile"]
casen[raw_salary>1000000 ,salary_quantile:="5. 5th quintile"]
casen[is.na(raw_salary)| raw_salary<=0,quantile:="0. No salary"]

#-------- Variables selection ####

#Identifying numeric variables which are not ids,nor expansion factors for correlations

numeric_casen<- casen[ , .SD, .SDcols = is.numeric]

non_id_list<-which(!names(numeric_casen) %like% "id")
numeric_casen <- numeric_casen[ ,..non_id_list] 

numeric_casen[,expr:=NULL]

#there is people without 

#Calculating Correlation
descrCor <- cor(numeric_casen,)

# Print correlation matrix 
print(descrCor)

corrplot(descrCor, order = "FPC", method = "color", tl.cex = 0.7, tl.col = rgb(0, 0, 0))

#this demonstrates that study years have a huge impact in raw salary, and a very weak correlation with family members and age. working hours may be an interesting variable.
#an important note is that age is not correlated with income, but it is with study years, therefore some models could use it, such as kmeans or neural network. also, to comply with literature of mincer equation, we could use it as a proxy for experience.

#now lets study the categorical columns

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

#there is a powerful significance and variance. Chile is a very segregated country, therefore the quality of the neighborhood is not so independent.

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


casen<- casen[,c("id",
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
                 "migrant",
                 "salary_quantile"
                 )]

#saving

fwrite(casen,"data\\processed\\Casen_2022_for_modeling.csv")
