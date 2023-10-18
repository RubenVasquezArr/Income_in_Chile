# -------------------------------- Casen 2022 processing --------------------------------#

#This script purpose is to filter and convert the raw data from casen 2022 survey.

#-------- Initial configuration ####

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())

# Trigger the garbage collector
gc()

#------- Open libraries
#install.packages("data.table")

#data table is the fastest and most powerful library for all data related operations. data.table > dplyr Always!!
library(data.table)

#readstata13 is the faster way to open dta files.
library(readstata13)

#-------- Open data
#choose.files()

#this should take a minute. or seconds, if your computer is better than mine
casen<-read.dta13("data\\raw\\Base de datos Casen 2022 STATA.dta")
casen<-as.data.table(casen)

#-------- initial exploration

names(casen)
#summary(casen)
#str(casen)
head(casen[,1:10])

#-------- data manipulation

#as detailed in the variables manual "Libro de códigos Base de datos Casen 2022.xlsx" (in the references files), for getting an individual id we have to paste the columns "folio" and  "id_persona"

casen[,id_indv:= paste0("folio",
                        "id_persona")]

#there is a lot of variables, but since we are going to study labor income, we will refer to the mincer equation (studies + experience) for independent variables

casen<-casen[,c("id_vivienda", #id from the house
                "folio", #id of the family group
                "id_indv", #id of the person
                "region", #Region of Chile
                "area", #Rural or urban
                "expr", #expansion factor for the region
                "nse", #socioeconomical level
                "p2", #general material condition of the sector
                "p3", #trash in the streets
                "p4", #vandalism, graffiti or damages in the sector
                "e1", #can write and read?
                "e3", #is studing now?
                "esc", #years of study
                "e6a", #higest academical degree
                "cinef13_area",#field of studies
                "o1", #work at least 1 hour last week
                "o4", #have ever worked
                "o6", #is in search for a job now?
                "oficio1_08", #field of work
                "o10", #working hours
                "o25", #size of business
                "y1", #salary (after taxes and others)
                "y2_hrs", #worked hours for that salary
                "yoprcor", #income from the principal occupation
                "ypch", #final per capita family income 
                "ytotcorh", #final family income  
                "ypc", #autonomous family income
                "r1a", #is migrant
                "pobreza",#poverty level
                "pueblos_indigenas", #is part of a indigenous people
                "numper", #number of family members 
                "men18c", #number of child in family
                "ind_hacina" #overcrowding level
                )]

#-------- saving

fwrite(casen,"data\\processed\\Casen_2022_processed.csv")

