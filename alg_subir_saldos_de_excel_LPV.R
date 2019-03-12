#Lectura HD (vamos a leer la historia hasta el ultimo dia disponible)
require(tidyverse)
require(readxl)

#Aca tenes que copiar el path del HD ultimo que tengas para modificar
#el path no puede ser asi C:\Users\Documents, tenes que cambiarlo a C:/Users/Documents
path_HD <- "D:/LP Villafuerte/Documents/Dropbox (Improgress)/TAVSA Development/Archivos LPV/HD-HDB-2019-03-09.csv"
HD <- read_csv(file = path_HD)

# **********************************************************************************************
# Codigo para pasar matriz con varias columnas a formato "tibble", con solo tres columnas, asi:
# # A tibble: 1,049,991 x 3
#      ATM Date       Retiro
# <dbl> <date>      <dbl>
#  1     1 2014-01-01   1900
#  2    13 2014-01-01  12800

HD <- HD%>%
  gather(2:ncol(HD), key = "Date", value = "Retiro")%>%
  dplyr::mutate(Retiro = as.numeric(Retiro),
                Date = as.Date(Date, format = "%Y-%m-%d"))%>%
  dplyr::mutate(Retiro = ifelse(is.na(Retiro),0,Retiro))%>%
  dplyr::filter(Retiro > 0)

# **********************************************************************************************
# Codigo para cargar data de ATMs nuevos y pasarla a formato "tibble"

path_HD_N_ATMs <- "D:/LP Villafuerte/Documents/Dropbox (Improgress)/TAVSA Development/Archivos LPV/Cambio de administracion_TAVSA_AGOSTO_2018 (1).xlsx"
HD_N_ATMs <- read_excel(path = path_HD_N_ATMs)

HD_N_ATMs <- HD_N_ATMs%>%
  gather(2:ncol(HD_N_ATMs), key = "Date", value = "Retiro")%>%
  dplyr::mutate(Retiro = as.numeric(Retiro),
                Date = as.Date(as.numeric(Date), origin="1899-12-30"))%>%
  dplyr::mutate(Retiro = ifelse(is.na(Retiro), 0, Retiro))%>%
  dplyr::filter(Retiro > 0)

# Codigo para depurar HD: Elimina data vieja de ATMs nuevos que está en HD
# Ayudita de Fernando Monzón... Filtra HD para remover (!) ATMs que están en Archivo Nuevo y tienen Data previa a fecha indicada

HD_Depurado <- HD%>%
  dplyr::filter(!(ATM %in% HD_N_ATMs$ATM & Date < "2018-08-01")) #La fecha corresponde a la fecha a partir que se tomó admin. de ATMs

# Codigo para unir HDs

HD_NEW <- rbind(HD_Depurado, HD_N_ATMs)
HD_NEW2 <- HD_NEW%>%
  spread(key = Date,value = Retiro,fill = 0)

#path para guardar el archivo
#el path no puede ser asi C:\Users\Documents, tenes que cambiarlo a C:/Users/Documents
path_HD_NEW2_save <- "D:/LP Villafuerte/Documents/Dropbox (Improgress)/TAVSA Development/Archivos LPV/HD-LPV-2019-03-12-ATMs201808.csv"
write_excel_csv(x = HD_NEW2, path = path_HD_NEW2_save)
