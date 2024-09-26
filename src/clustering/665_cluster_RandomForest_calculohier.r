# ideas para un clustering derivado del Machnie Learning
# limpio la memoria
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

# leo el dataset
dataset <- fread(PARAM$dataset)


# creo la carpeta donde va el experimento
dir.create("./exp/", showWarnings = FALSE)
dir.create(paste0("./exp/", PARAM$experimento, "/"), showWarnings= FALSE)

# Establezco el Working Directory DEL EXPERIMENTO
setwd(paste0("./exp/", PARAM$experimento, "/"))


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

# invoco a la distancia de Random Forest
 # ahora, a esperar .. con esta libreria de la prehistoria
#  que NO corre en paralelo

set.seed(PARAM$semilla_primigenia)

modelo <- randomForest( 
  x= dchico[, campos_cluster, with=FALSE ],
  y= NULL,
  ntree= 10000, #se puede aumentar a 10000
  proximity= TRUE,
  oob.prox=  TRUE )

# genero los clusters jerarquicos
# distancia = 1.0 - proximidad
hclust.rf <- hclust( 
  as.dist ( 1.0 - modelo$proximity),
  method= "ward.D2" )


# imprimo un pdf con la forma del cluster jerarquico

pdf( "cluster_jerarquico.pdf" )
plot( hclust.rf )
dev.off()

# guardo el hclust.rf
saveRDS( hclust.rf, "hclust.rf.rds" )