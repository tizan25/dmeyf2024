rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")
require("ggplot2")
require("RColorBrewer")
require("ggallin")

require("randomForest")
require("ranger")

PARAM <- list()
PARAM$experimento <- "clu-randomforest-end"
PARAM$semilla_primigenia <- 168943   # aqui va SU semilla
PARAM$dataset <- "C:/users/santy/desktop/python/maestria/2024/DMEyF/datasets/competencia_01.csv"


#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Aqui empieza el programa
setwd("C:/users/santy/desktop/python/maestria/2024/DMEyF")

dataset <- fread(PARAM$dataset)

# campos arbitrarios, solo como ejemplo
# usted DEBE MANDARIAMENTE agregar más campos aqui
# no permita que la pereza se apodere de su alma
campos_cluster <- c("active_quarter", "cliente_vip", "internet", "cliente_edad",
                    "cliente_antiguedad", "mrentabilidad", "mcaja_ahorro", "cdescubierto_preacordado",
                    "mcuentas_saldo", "mautoservicio", "mtarjeta_visa_consumo", "mtarjeta_master_consumo",
                    "mprestamos_personales", "cinversion1", "cinversion2", "ccaja_seguridad",
                    "mpayroll", "thomebanking", "chomebanking_transacciones", "ccajas_transacciones",
                    "tcallcenter", "catm_trx_other", "ctrx_quarter", "Visa_status", "Master_status",
                    "Master_mlimitecompra", "Visa_mlimitecompra", "Master_mconsumototal", "Visa_mconsumototal")


# genero el dataset chico
dchico <- dataset[
  clase_ternaria=="BAJA+2", 
  c("numero_de_cliente",campos_cluster),
  with=FALSE]

# arreglo los valores NA
dchico  <- na.roughfix( dchico )
# no hace falta escalar


set.seed(PARAM$semilla_primigenia)

# cargo el hclust.rf
hclust.rf <- readRDS("./exp/clu-randomforest-end/hclust.rf.rds")

kclusters <- 4  # cantidad de clusters
h <- 20
distintos <- 0

while(  h>0  &  !( distintos >=kclusters & distintos <=kclusters ) )
{
  h <- h - 1
  rf.cluster <- cutree( hclust.rf, h)
  
  dchico[, cluster := paste0("cluster_", rf.cluster) ]
  
  distintos <- nrow( dchico[, .N, cluster ] )
  cat( distintos, " " )
}


#--------------------------------------

setorder( dchico, cluster, numero_de_cliente )

#--------------------------------------
# Analisis de resultados del clustering jerarquico
# cantidad de registros por cluster

dcentroides <- dchico[, lapply(.SD, mean, na.rm=TRUE), 
                      by= cluster, 
                      .SDcols= campos_cluster ]


# leo la historia ( desde donde hay,  202101 )
dhistoria <- fread(PARAM$dataset)
thewalkingdead <- dhistoria[ clase_ternaria =="BAJA+2", unique(numero_de_cliente) ]

dwalkingdead <- dhistoria[ numero_de_cliente %in% thewalkingdead ]


# asigno el cluster a los 
dwalkingdead[ dchico,
              on= "numero_de_cliente",
              cluster := i.cluster ]

# asigno cuentra regresiva antes de la BAJA
setorder( dwalkingdead, numero_de_cliente, -foto_mes )

dwalkingdead[, periodo := - rowid(numero_de_cliente)]

# ejemplo
dwalkingdead[numero_de_cliente==249458924, list( numero_de_cliente, foto_mes, periodo ) ]


# grafico la evolucion de cada < cluster, variable >  univariado ------

# todos los campos menos los que no tiene sentido
campos_totales <- setdiff( colnames(dwalkingdead),
                           c("numero_de_cliente","foto_mes","clase_ternaria","cluster","periodo") )

fwrite( dwalkingdead, "C:/users/santy/desktop/python/maestria/2024/DMEyF/datasets/dwalkingdead.csv" )


ggplot( dwalkingdead[periodo >= -6],
        aes_string(x= "periodo",
                   y= "Master_mconsumototal",
                   color= "cluster"))  +
  scale_colour_brewer(palette= "Dark2") +
  xlab("periodo") +
  ylab("") +
  geom_smooth( method= "loess", level= 0.95,  na.rm= TRUE )


for( campo in campos_totales ) {
  
  cat( campo, " " )
  
  grafico <- ggplot( dwalkingdead[periodo >= -6],
                     aes_string(x= "periodo",
                                y= campo,
                                color= "cluster"))  +
    scale_colour_brewer(palette= "Dark2") +
    xlab("periodo") +
    ylab(campo) +
    geom_smooth( method= "loess", level= 0.95,  na.rm= TRUE )
  
  print( grafico )
}

