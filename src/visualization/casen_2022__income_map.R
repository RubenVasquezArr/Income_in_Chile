gc()

# Clear the console
cat("\014")

# Clear the workspace
rm(list = ls())


options(scipen = 999)


#libraries

library(data.table)
library(ggplot2)
library(leaflet)
library(sf)
library(chilemapas)
library(sp)
library(htmlwidgets)

#data
casen<-fread("data\\processed\\Casen_2022_processed.csv",stringsAsFactors = T)

casen<-casen[!is.na(raw_salary) &
               raw_salary > 0,]

chile <- casen[rep(1:.N,expr)]

chile[,region:= factor(region, levels = c(
  "Región de Arica y Parinacota",
  "Región de Tarapacá",
  "Región de Antofagasta",
  "Región de Atacama",
  "Región de Coquimbo",
  "Región de Valparaíso",
  "Región Metropolitana de Santiago",
  "Región del Libertador Gral. Bernardo O'Higgins",
  "Región del Maule",
  "Región de Ñuble",
  "Región del Biobío",
  "Región de La Araucanía",
  "Región de Los Ríos",
  "Región de Los Lagos",
  "Región de Aysén del Gral. Carlos Ibáñez del Campo",
  "Región de Magallanes y de la Antártica Chilena"))]

geo_regions <- generar_regiones()
geo_regions <-sf::st_transform(geo_regions,'+proj=longlat +datum=WGS84')




geo_regions$region<-""

geo_regions$region[geo_regions$codigo_region == "01"]<-"Región de Tarapacá"
geo_regions$region[geo_regions$codigo_region == "02"]<-"Región de Antofagasta"
geo_regions$region[geo_regions$codigo_region == "03"]<-"Región de Atacama"
geo_regions$region[geo_regions$codigo_region == "04"]<-"Región de Coquimbo"
geo_regions$region[geo_regions$codigo_region == "05"]<-"Región de Valparaíso"
geo_regions$region[geo_regions$codigo_region == "06"]<-"Región del Libertador Gral. Bernardo O'Higgins"
geo_regions$region[geo_regions$codigo_region == "07"]<-"Región del Maule"
geo_regions$region[geo_regions$codigo_region == "08"]<-"Región del Biobío"
geo_regions$region[geo_regions$codigo_region == "09"]<-"Región de La Araucanía"
geo_regions$region[geo_regions$codigo_region == "10"]<-"Región de Los Lagos"
geo_regions$region[geo_regions$codigo_region == "11"]<-"Región de Aysén del Gral. Carlos Ibáñez del Campo"
geo_regions$region[geo_regions$codigo_region == "12"]<-"Región de Magallanes y de la Antártica Chilena"
geo_regions$region[geo_regions$codigo_region == "13"]<-"Región Metropolitana de Santiago"
geo_regions$region[geo_regions$codigo_region == "14"]<-"Región de Los Ríos"
geo_regions$region[geo_regions$codigo_region == "15"]<-"Región de Arica y Parinacota"
geo_regions$region[geo_regions$codigo_region == "16"]<-"Región de Ñuble"

regions_data<-chile[, .(median_salary = median(raw_salary)), by = region]

geo_regions<-merge(geo_regions, regions_data, by = "region")

# Define la paleta de colores
colors <- colorNumeric(palette = "YlOrRd", domain = geo_regions$median_salary)
colors_inv <- colorNumeric(palette = "YlOrRd", domain = geo_regions$median_salary, reverse = TRUE)


geo_regions <-sf::st_simplify(geo_regions, dTolerance = 0.01)
geo_regions2 <-sf::st_simplify(geo_regions, dTolerance = 0.05)
geo_regions3 <-sf::st_simplify(geo_regions, dTolerance = 0.1)
geo_regions4<-sf::st_simplify(geo_regions, dTolerance = 1000)
geo_regions<-geo_regions4

object.size(geo_regions)
object.size(geo_regions2)
object.size(geo_regions4)
object.size(geo_regions)


# Crea el mapa Leaflet
map <- leaflet(data = geo_regions) %>%
  addTiles() %>% # Puedes cambiar el proveedor de mapas
  addPolygons(
    fillColor = ~colors(median_salary),
    fillOpacity = 0.7,
    color = "white",
    weight = 1,
    popup = ~paste("Region: ", region, "<br>",
                   "Median salary: ", median_salary)
  ) %>%
  addLegend(
    position = "bottomright",
    pal = colors_inv,
    values = ~median_salary,
    title = "Median salary",
    labFormat = labelFormat(transform = function(median_salary) sort(median_salary, decreasing = TRUE)))


# Muestra el mapa
map

saveWidget(
  map, file = "Chile_income_map.html",
  selfcontained = TRUE)
