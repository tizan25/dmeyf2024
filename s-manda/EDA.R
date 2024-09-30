library(data.table)
library(ggplot2)
library(glue)

# leo el dataset
dataset <- fread("C:/users/santy/desktop/python/maestria/2024/DMEyF/datasets/competencia_01.csv")

# selecciono los baja+2
dataset <- dataset[clase_ternaria=="BAJA+2", ]

# selecciono una variable para hacer un histograma
# y ver como se distribuye
var = "Master_mconsumototal"

ggplot(data=dataset, aes(x=dataset[[var]])) +
  geom_histogram(bins=30, fill="blue", color="black") +
  ggtitle(glue("Distribución de la variable {var}")) +
  xlab(var) +
  ylab("Frecuencia") +
  theme_minimal()

summary(dataset[[var]])

# selecciono una variable categorica para ver valores
# y ver como se distribuye, en este caso la variable
# es internet
var2 = "cdescubierto_preacordado"

ggplot(data=dataset, aes(x=dataset[[var2]])) +
  geom_bar(fill="blue", color="black") +
  ggtitle(glue("Distribución de la variable {var2}")) +
  xlab(var2) +
  ylab("Frecuencia") +
  theme_minimal()

summary(dataset[[var2]])
