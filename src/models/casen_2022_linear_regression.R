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


library(data.table)



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




