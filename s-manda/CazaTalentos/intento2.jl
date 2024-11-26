using Random
using Statistics
using DataFrames

# Definir una función auxiliar para los tiros
function ftirar(prob, qty)
    return sum(rand() < prob for i in 1:qty)
end


# Variable global para las funciones del gimnasio
GLOBAL_gimnasio = Dict()

# Inicializar el gimnasio
# Asigna una precisión de tiro a cada jugadora que no puede ser vista por la cazatalentos
function gimnasio_init()
    GLOBAL_gimnasio[:taurasita] = 0.5
    GLOBAL_gimnasio[:jugadoras] = shuffle(append!([0.204:0.002:0.400;],
        GLOBAL_gimnasio[:taurasita]))

    GLOBAL_gimnasio[:tiros_total] = 0
end

# Toma una lista de IDs de jugadoras y la cantidad de tiros a realizar
# Devuelve el número de encestes para cada jugadora
function gimnasio_tirar(pids, pcantidad)
    GLOBAL_gimnasio[:tiros_total] += length(pids) * pcantidad
    return [ftirar(GLOBAL_gimnasio[:jugadoras][id], pcantidad) for id in pids]
end

# La cazatalentos elige una jugadora
# Devuelve la cantidad total de tiros y si acerto a la verdadera mejor
function gimnasio_veredicto(jugadora_id)
    return Dict(
        "tiros_total" => GLOBAL_gimnasio[:tiros_total],
        "acierto" => Int(GLOBAL_gimnasio[:jugadoras][jugadora_id] == GLOBAL_gimnasio[:taurasita])
    )
end

#------------------------------------------------------------------------------
# Realizar una ronda eliminatoria
# Las jugadoras con activa == 1 hacer tiros libres
# y son eliminadas si están por debajo de cierto umbral

function ronda_eliminatoria!(planilla, tiros, desvios)
    # Si no hay jugadoras activas o no hay tiros, salir de la función
    if sum(planilla[!, :activa] .== 1) == 0 || tiros < 1
        return
    end

    ids_juegan = planilla[planilla[!, :activa].==1, :id]
    resultados = gimnasio_tirar(ids_juegan, tiros)
    planilla[planilla[!, :activa].==1, :encestes] .= resultados

    # Calcular la cantidad mínima de encestes para pasar a la siguiente ronda
    encestes_corte = mean(planilla[planilla[!, :activa].==1, :encestes]) +
                     desvios * std(planilla[planilla[!, :activa].==1, :encestes])

    # Poner en estado inactivo a las jugadoras por debajo del umbral
    for i in eachindex(planilla[!, :id])
        if planilla[!, :activa][i] == 1 && planilla[!, :encestes][i] < encestes_corte
            planilla[!, :activa][i] = 0
        end
    end
end


# Estrategia con ε-greedy con decay
function Estrategia_EpsilonGreedy()
    gimnasio_init() # inicializar el gimnasio

    # Crear la planilla de la cazatalentos
    planilla_cazatalentos = DataFrame(
        id=[1:1:100;], # Número de la jugadora
        activa=ones(Int, 100), # Todas activas inicialmente
        encestes=zeros(Int, 100), # Cero encestes
        calidad=zeros(Float64, 100) # Estimación de calidad inicial
    )

    # Parámetros iniciales de ε-greedy
    epsilon = 1.0  # Probabilidad inicial de exploración
    decay = 0.999    # Decay de ε por ronda

    # Número de tiros por ronda
    tiros_rondas = [37, 45, 50, 200]

    for tiros in tiros_rondas
        # Obtener IDs de las jugadoras activas
        ids_activas = planilla_cazatalentos[planilla_cazatalentos[!, :activa].==1, :id]

        if isempty(ids_activas)
            break
        end

        # Hacer tiros y actualizar estimaciones de calidad
        resultados = gimnasio_tirar(ids_activas, tiros)
        for i in 1:length(ids_activas)
            id = ids_activas[i]
            # Actualizar calidad estimada (media acumulada)
            prev_calidad = planilla_cazatalentos[!, :calidad][id]
            n_tiros_prev = sum(planilla_cazatalentos[!, :id] .== id)
            planilla_cazatalentos[!, :calidad][id] = (prev_calidad * n_tiros_prev + resultados[i]) / (n_tiros_prev + 1)
        end

        # Selección ε-greedy para la siguiente ronda
        for i in eachindex(planilla_cazatalentos[!, :id])
            if planilla_cazatalentos[!, :activa][i] == 1
                if rand() < epsilon
                    # Exploración: mantener activa con probabilidad ε
                    continue
                else
                    # Explotación: mantener solo si su calidad está entre las mejores
                    calidad_minima = mean(planilla_cazatalentos[!, :calidad]) +
                                     std(planilla_cazatalentos[!, :calidad])
                    if planilla_cazatalentos[!, :calidad][i] < calidad_minima
                        planilla_cazatalentos[!, :activa][i] = 0
                    end
                end
            end
        end

        # Decay de ε
        epsilon *= decay
    end

    # Elegir la mejor jugadora entre las activas
    activas_finales = planilla_cazatalentos[planilla_cazatalentos[!, :activa].==1, :]
    if isempty(activas_finales)
        return gimnasio_veredicto(-1) # Ninguna seleccionada
    end

    pos_mejor = argmax(activas_finales[!, :calidad])
    jugadora_mejor = activas_finales[!, :id][pos_mejor]

    return gimnasio_veredicto(jugadora_mejor)
end


# ------------------------------------------------------------------------------

@time begin  # Mido el tiempo

    # Estimación Montecarlo para Estrategia con ε-greedy con decay
    Random.seed!(168943)  # Fijo semilla para reproducibilidad

    tabla_veredictos = DataFrame(tiros_total=Int[], acierto=Int[])

    # Repetimos el experimento
    for experimento in 1:100000  # Repeticiones Monte Carlo
        if experimento % 10000 == 0
            print(experimento, " ")
        end

        veredicto = Estrategia_EpsilonGreedy()
        push!(tabla_veredictos, veredicto)
    end

    println()

    # Calculo métricas
    tiros_media = mean(tabla_veredictos.tiros_total)
    tasa_eleccion_correcta = mean(tabla_veredictos.acierto)

    println("La tasa de elección de la verdadera mejor es: ", tasa_eleccion_correcta)
    println("La cantidad de tiros promedio en lograrlo es: ", tiros_media)

end
