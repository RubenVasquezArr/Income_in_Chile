# -------------------------------- Casen 2022 processing --------------------------------#

#This script purpose is to filter and convert the raw data from casen 2022 survey.

#-------- Initial configuration ####

# Trigger the garbage collector
gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())

#------- Open libraries ####
#install.packages("data.table")

#data table is the fastest and most powerful library for all data related operations. data.table > dplyr !! :)
library(data.table)

#readstata13 is the faster way to open dta files.
library(readstata13)

#-------- Open data ####
#choose.files()

#this should take a minute. 
casen<-read.dta13("data\\raw\\Base de datos Casen 2022 STATA.dta")
casen<-as.data.table(casen)
#the database can be downloaded at https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen-2022 -> Base de datos ->	"Base de datos Casen 2022 STATA (versión 20 de octubre 2023)"	

#-------- Initial exploration ####

names(casen)
#summary(casen)
#str(casen)
head(casen[,1:10])

#-------- Data manipulation ####

#as detailed in the variables manual "Libro de códigos Base de datos Casen 2022.xlsx"  to obtain an individual ID, we need to concatenate the 'folio' and 'id_persona' columns.

casen[,id_indv:= paste0(folio,
                        id_persona)]

#there are numerous variables available, but since we are going to study labor income, we will refer to the mincer equation (studies + experience) for independent variables, and others that seem interesting or potentially useful

casen<-casen[,c("id_vivienda", #id from the house
                "folio", #id of the family group
                "id_indv", #id of the person
                "region", #Region of Chile
                "area", #Rural or urban
                "expr", #expansion factor for the region
                "edad", #age of the person
                "sexo", #gender
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
                "y1", #raw_salary
                "r1a", #is migrant
                "pobreza",#poverty level
                "pueblos_indigenas", #is part of a indigenous comunity
                "numper", #number of family members
                "ind_hacina" #overcrowding level
                )]


#lets change some names to remember them better

names(casen)[which(names(casen)=="id_vivienda")]<-"id_house"
names(casen)[which(names(casen)=="folio")]<-"id_family"
names(casen)[which(names(casen)=="area")]<-"rural_or_urban"
names(casen)[which(names(casen)=="edad")]<-"age"
names(casen)[which(names(casen)=="sexo")]<-"gender"
names(casen)[which(names(casen)=="nse")]<-"socioec_level"
names(casen)[which(names(casen)=="p2")]<-"sector_quality"
names(casen)[which(names(casen)=="p3")]<-"sector_trash"
names(casen)[which(names(casen)=="p4")]<-"sector_vandlsm"
names(casen)[which(names(casen)=="e1")]<-"can_read"
names(casen)[which(names(casen)=="e3")]<-"is_studing"
names(casen)[which(names(casen)=="esc")]<-"study_years"
names(casen)[which(names(casen)=="e6a")]<-"acad_level"
names(casen)[which(names(casen)=="cinef13_area")]<-"study_field"
names(casen)[which(names(casen)=="o1")]<-"is_working"
names(casen)[which(names(casen)=="o4")]<-"ever_worked"
names(casen)[which(names(casen)=="o6")]<-"searchn_job"
names(casen)[which(names(casen)=="oficio1_08")]<-"work_field"
names(casen)[which(names(casen)=="o10")]<-"working_hours"
names(casen)[which(names(casen)=="o25")]<-"business_size"
names(casen)[which(names(casen)=="y1")]<-"raw_salary"
names(casen)[which(names(casen)=="r1a")]<-"migrant"
names(casen)[which(names(casen)=="pobreza")]<-"poverty_level"
names(casen)[which(names(casen)=="pueblos_indigenas")]<-"indgn_comunity"
names(casen)[which(names(casen)=="numper")]<-"family_members"
names(casen)[which(names(casen)=="ind_hacina")]<-"overcrwdng_level"


#-------- Saving ####

fwrite(casen,"data\\processed\\Casen_2022_processed.csv")

