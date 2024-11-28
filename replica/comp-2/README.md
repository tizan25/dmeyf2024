# Replicabilidad para 2da competencia DMEYF2024
Integrantes: Santiago Bezchinsky

## Pasos
1. Editar la ruta del archivo en "909_run_order277.r" para apuntar al directorio del script
2. Ejecutar el archivo "909_run_order277.r"

## Notas 
El workflow esta basado en el Workflow UBA (WUBA) utilizando el semillerío.
Modificaciones principales al baseline:
- Feature engineering: se agrega una variable que suma las variables de transacciones
- FE Histórico: se usan lags 1 y 2 (mas deltas) y las tendencias de 6 y 12 meses, usando ratios y promedios
- FE Random Forest: se usan 25 arboles de 16 hojas cada uno.
- TS: se agregan meses de entrenamiento (201901 y 02) y se quitan marzo y abril para todos los años. También se reduce el undersampling, elevando el parámetro a 0.04 tanto en training como en final train
- FM: el semillerio se repite 2 veces, con 50 semillas cada uno

