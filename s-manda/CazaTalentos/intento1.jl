using Random, Statistics, Dates

function epsilon_n_greedy(true_probs, num_throws, epsilon_start=1.0, epsilon_decay=0.001)
    """
    Epsilon-n-Greedy algorithm to identify the best basketball free throw shooter.

    Parameters:
    - num_players::Int: Number of players.
    - true_probs::Vector{Float64}: True probabilities of making a free throw for each player.
    - num_throws::Int: Total number of free throws allowed.
    - epsilon_start::Float64: Initial exploration rate.
    - epsilon_decay::Float64: Decay factor for exploration rate.

    Returns:
    - best_player::Int: Index of the player with the highest estimated success rate.
    """
    # Initialize success counts and throw counts
    num_players = length(true_probs)
    successes = zeros(Float64, num_players)
    player_throws = zeros(Int, num_players)

    for t in 1:num_throws
        # Compute epsilon for the current step
        epsilon = max.(epsilon_start / (1 + epsilon_decay * t), 0.00001)

        # Decide whether to explore or exploit
        if rand() < epsilon
            # Explore: Choose a random player
            chosen_player = rand(1:num_players)
        else
            # Exploit: Choose the player with the highest estimated success rate
            estimated_probs = successes ./ max.(player_throws, 1)
            chosen_player = argmax(estimated_probs)
        end

        # Simulate the result of the chosen player's free throw
        reward = rand() < true_probs[chosen_player]

        # Update the success and throw counts for the chosen player
        successes[chosen_player] += reward
        player_throws[chosen_player] += 1
    end

    # Compute final estimated probabilities
    estimated_probs = successes ./ max.(player_throws, 1)

    # Identify the player with the highest estimated success rate
    best_player = argmax(estimated_probs)
    return best_player
end

function simulate_epsilon_n_greedy_experiments(num_throws, epsilon_start, epsilon_decay, true_probs, num_experiments)
    """
    Simulates multiple epsilon-n-greedy experiments to estimate the probability of selecting the best player.

    Parameters:
    - num_players::Int: Number of players.
    - num_throws::Int: Total number of free throws allowed per experiment.
    - epsilon_start::Float64: Initial exploration rate.
    - epsilon_decay::Float64: Decay factor for exploration rate.
    - true_probs::Vector{Float64}: True probabilities of making a free throw for each player.
    - num_experiments::Int: Number of experiments to simulate.

    Returns:
    - success_rate::Float64: Probability of correctly identifying the best player.
    """
    true_best_player = argmax(true_probs)
    successes = 0

    for i in 1:num_experiments
        best_player = epsilon_n_greedy(true_probs, num_throws, epsilon_start, epsilon_decay)
        successes += (best_player == true_best_player ? 1 : 0)

        if i % 1000 == 0
            println("Experiment $i: Success rate = $(successes / i)")
        end
    end

    return successes / num_experiments
end

# Ejemplo de uso
function main()
    # Definir las probabilidades reales de los jugadores
    num_players = 100  # Número de jugadores
    # probabilidades de 99 jugadores de 0.204, 0.206, 0.208, …, 0.400
    true_probs = [0.204 + 0.002 * i for i in 0:98] .+ 0.002
    push!(true_probs, 0.5)  # Agregar un jugador con probabilidad 0.5
    num_throws = 5000  # Número de lanzamientos por experimento
    epsilon_start = 1.0  # Tasa de exploración inicial
    epsilon_decay = 0.0001  # Factor de decaimiento de exploración
    num_experiments = 10000  # Número de experimentos a simular

    # Establecer semilla
    Random.seed!(1234)

    # Medir el tiempo de ejecución
    println("Iniciando simulación. Tiros por experimento: $num_throws, Epsilon decay: $epsilon_decay")
    start_time = now()
    success_rate = simulate_epsilon_n_greedy_experiments(
        num_throws, epsilon_start, epsilon_decay, true_probs, num_experiments
    )
    end_time = now()

    println("Tasa de éxito (probabilidad de elegir al mejor jugador): $(round(success_rate, digits=4))")
    println("Tiempo total de ejecución: $(end_time - start_time)")
end

main()