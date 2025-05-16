##recorte de variables oceanográficas
#OJO: el polígono ya debe estar creado y las variables deben estar a la misma resolución espacial
#carpeta de la clase 04
setwd("D:/CURSO IMIPAS/clase 04")
#cargamos las librerias raster y sf, en caso de no tenerlas, deberá instalarlas
library(raster)
library(sf)
#indicamos como se llama nuestro archivo shapefile que usaremos para el recorte, deberás reemplazar este polígono por el
#de tu área de estudio e indicar como se llama el archivo
poligono="area_PN"
#cargamos el archivo
shape <- read_sf(dsn = "D:/CURSO IMIPAS/clase 04", layer = poligono)
#cambiamos la carpeta de trabajo a la carpeta donde están las variables

setwd("D:/CURSO IMIPAS/clase 04/variables")
#creamos una lista con los nombres de las variables, en este caso son extensión .asc, si sus raster son .tif deberá modificar a pattern=".tif"
lista=list.files(pattern=".asc")
# creamos un ciclo, en el que se leera una variable en cada iteración, la recortará con el polígono y se guardará este archivo recortado
for(i in 1: length(lista))
{
#leemos el raster
r=raster(lista[i])
# cortamos el raster a la extensión del shape (latitudes y longitudes)
r2 <- crop(r, extent(shape))
#cortamos el poligono con el shape ya con su forma irregluar
r3 <- mask(r2, shape)
#agregamos el sufijo "rec_" para diferenciar archivos recortados y no sobreescribir y eliminar los archivos base

nombre=paste("rec_",lista[i],sep="")
#guardamos el acrhivo
writeRaster(r3, nombre, format="ascii", overwrite = T)
plot(r3)
}
