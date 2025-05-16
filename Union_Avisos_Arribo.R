setwd("G:/INAPESCA/USB/TRABAJO/Base 2025/Bases Arribo 2000-2024")


# Cargar la biblioteca necesaria
library(dplyr)


# 1. Especifica la ruta de la carpeta que contiene los archivos CSV
carpeta <- "G:/INAPESCA/USB/TRABAJO/Base 2025/Bases Arribo 2000-2024"


# 2. Lista todos los archivos CSV en la carpeta
archivos_csv <- list.files(path = carpeta, pattern = "\\.csv$", full.names = TRUE)

# Verifica si hay archivos CSV en la carpeta
if (length(archivos_csv) == 0) {
  stop("No se encontraron archivos CSV en la carpeta especificada.")
}

# 3. Lee cada archivo CSV, normaliza los nombres de las columnas y almacena los data frames en una lista
dataframes <- lapply(archivos_csv, function(archivo) {
  # Lee el archivo CSV con la codificación correcta (UTF-8 es común para caracteres especiales)
  df <- read.csv(archivo, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  
  # Normaliza los nombres de las columnas
  colnames(df) <- gsub(" ", "_", tolower(colnames(df))) # Convierte a minúsculas y reemplaza espacios
  colnames(df) <- gsub("-", "_", colnames(df)) # Reemplaza guiones por "_"
  colnames(df) <- gsub("[^a-zA-Z0-9_]", "", colnames(df)) # Elimina caracteres especiales
  
  return(df)
})

# 4. Imprime los nombres de las columnas de cada data frame para depuración
cat("Nombres de columnas por archivo:\n")
for (i in seq_along(dataframes)) {
  cat("Archivo:", archivos_csv[i], "\n")
  cat("Columnas:", paste(colnames(dataframes[[i]]), collapse = ", "), "\n\n")
}

# 5. Encuentra las columnas comunes a todos los data frames
columnas_comunes <- Reduce(intersect, lapply(dataframes, colnames))

# Verifica si hay columnas comunes
if (length(columnas_comunes) == 0) {
  stop("No hay columnas comunes entre los archivos CSV.")
}

# 6. Filtra cada data frame para conservar solo las columnas comunes
dataframes_filtrados <- lapply(dataframes, function(df) {
  df %>% select(all_of(columnas_comunes))
})

# 7. Convierte las columnas comunes al mismo tipo de datos (todas a character)
dataframes_filtrados <- lapply(dataframes_filtrados, function(df) {
  df %>% mutate(across(everything(), as.character))
})

# 8. Combina todos los data frames filtrados en uno solo
df_final <- bind_rows(dataframes_filtrados)

# 9. Muestra el data frame final (opcional)
print(head(df_final))

# 10. Guarda el data frame final en un nuevo archivo CSV (opcional)
#write.csv(df_final, file = "archivo_final_AVISOS.csv", row.names = FALSE, fileEncoding = "UTF-8")


#save.image(file = "entorno_completo.RData")
load("entorno_completo.RData")

# Vamos seleccionar solo los estados del Golfo de Mexico y Caribe 
df_final$nombreestado<-as.factor(df_final$nombreestado)

# Definir los elementos que quieres filtrar
EstadosGolfo <- c("QUINTANA ROO","YUCATAN","CAMPECHE", "TABASCO", "VERACRUZ","TAMAULIPAS")

# Filtrar el DataFrame a estados del Golfo
BASE <- subset(df_final, nombreestado %in% EstadosGolfo)
# cambiar a factor los meses y año
mescorte <- c("ENERO","FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE","OCTUBRE",
              "NOVIEMBRE", "DICIEMBRE")

BASE$mescorte <- factor(BASE$mescorte,levels = mescorte)
BASE$aocorte <- as.factor(BASE$aocorte)
BASE$pesovivo <- sub(",.*", "", BASE$pesovivo)
BASE$pesovivo <- as.numeric(BASE$pesovivo)

BASE$claveespecie <- as.factor(BASE$claveespecie)
cangrejos <- c("1940220H","1941418H","1941426H","1943224H","1951425H","1960228H","1961424H","1981422H")
# Extraer solo información de cangrejo
BASECangrejo <- subset(BASE, claveespecie %in% cangrejos)
BASECangrejo$nombreespecie <- as.factor(BASECangrejo$nombreespecie)
BASECangrejo$pesodesembarcado <- as.numeric(BASECangrejo$pesodesembarcado)

plot(BASECangrejo$mescorte, BASECangrejo$pesovivo)
plot(BASECangrejo$mescorte, BASECangrejo$pesodesembarcado)


Cangrejo<-BASECangrejo %>%
  group_by(aocorte) %>%
  summarise(ABU_Peso = mean(pesovivo))
