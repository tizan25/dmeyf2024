import numpy as np
import pandas as pd
import time
import os

current = os.getcwd()


DIR = os.path.abspath(os.path.join(current, '../../buckets/b1/datasets'))

# Cargamos los datos
print('Cargando datos...')
data = pd.read_csv(f'{DIR}/competencia_02_crudo.csv.gz')

# Inicio del proceso
print('Procesando...')
start_time = time.time()

# Trabajamos solamente con las columnas necesarias
clientes = data[['numero_de_cliente', 'foto_mes']].copy(
).sort_values(['numero_de_cliente', 'foto_mes'])

# Convertimos foto mes a un periodo numérico secuencial
clientes['periodo0'] = clientes['foto_mes'].floordiv(
    100).mul(12) + clientes['foto_mes'].mod(100)

# Calculamos el último y anteúltimo periodo
ultimo = clientes['periodo0'].max()
anteultimo = ultimo - 1

# Creamos los leads de período según cliente
groupper = clientes.groupby('numero_de_cliente')['periodo0']
clientes['periodo1'] = groupper.shift(-1)
clientes['periodo2'] = groupper.shift(-2)

# Si el cliente tiene vacío periodo 1, es BAJA+1, si tiene vacío periodo 2, es BAJA+2
clientes['clase_ternaria'] = np.where(clientes['periodo0'] == ultimo, pd.NA,
                                      np.where(clientes['periodo1'].isna(), 'BAJA+1',
                                               np.where(clientes['periodo0'] == anteultimo, pd.NA,
                                                        np.where(clientes['periodo2'].isna(), 'BAJA+2', 'CONTINUA'))))

# Fin del proceso
print('Tiempo de procesamiento:', round(
    time.time() - start_time, 4), 'segundos.')

# Guardamos el dataset
print('Guardando datos...')
data.join(clientes['clase_ternaria']).to_csv(
    f'{DIR}/competencia_02.csv.gz', index=False)

# Mostramos la distribución de clases
print('Distribución de clases:')
print(clientes['clase_ternaria'].value_counts(
    normalize=True).mul(100).round(2))
