import numpy as np
from time import time


def ucb(num_players, true_probs, num_throws, c=2):
    """
    UCB (Upper Confidence Bound) algorithm to identify the best basketball free throw shooter.

    Parameters:
    - num_players (int): Number of players.
    - true_probs (np.array): True probabilities of making a free throw for each player.
    - num_throws (int): Total number of free throws allowed.
    - c (float): Exploration parameter (controls the level of exploration).

    Returns:
    - best_player (int): Index of the player with the highest estimated success rate.
    """
    # Initialize success counts and throw counts
    successes = np.zeros(num_players, dtype=np.float32)
    player_throws = np.zeros(num_players, dtype=np.int32)

    # Pull each arm once to initialize
    for player in range(num_players):
        reward = np.random.rand() < true_probs[player]
        successes[player] += reward
        player_throws[player] += 1

    for t in range(num_players, num_throws):
        # Compute UCB values for all players
        estimated_probs = successes / player_throws
        confidence_bounds = c * np.sqrt(np.log(t + 1) / player_throws)
        ucb_values = estimated_probs + confidence_bounds

        # Select the player with the highest UCB value
        chosen_player = np.argmax(ucb_values)

        # Simulate the result of the chosen player's free throw
        reward = np.random.rand() < true_probs[chosen_player]

        # Update the success and throw counts for the chosen player
        successes[chosen_player] += reward
        player_throws[chosen_player] += 1

    # Compute final estimated probabilities
    estimated_probs = successes / player_throws

    # Identify the player with the highest estimated success rate
    best_player = np.argmax(estimated_probs)

    return best_player


def simulate_ucb_experiments(num_players, num_throws, c, true_probs, num_experiments):
    """
    Simulates multiple UCB experiments to estimate the probability of selecting the best player.

    Parameters:
    - num_players (int): Number of players.
    - num_throws (int): Total number of free throws allowed per experiment.
    - c (float): Exploration parameter.
    - true_probs (np.array): True probabilities of making a free throw for each player.
    - num_experiments (int): Number of experiments to simulate.

    Returns:
    - success_rate (float): Probability of correctly identifying the best player.
    """
    true_best_player = np.argmax(true_probs)
    successes = 0

    for i in range(num_experiments):
        best_player = ucb(num_players, true_probs, num_throws, c)
        successes += (best_player == true_best_player)

        if i % 500 == 0:
            print(f"Experimento {i + 1} de {num_experiments} completado.")

    return successes / num_experiments


# Ejemplo optimizado
if __name__ == "__main__":
    # Definir las probabilidades reales de los jugadores
    true_probs = np.linspace(0.204, 0.400, 99)
    true_probs = np.append(true_probs, 0.5)

    num_players = len(true_probs)
    num_throws = 10000  # Número de lanzamientos por experimento
    c = 2  # Parámetro de exploración
    num_experiments = 10000  # Número de experimentos a simular

    start_time = time()

    # Ejecutar las simulaciones
    success_rate = simulate_ucb_experiments(
        num_players, num_throws, c, true_probs, num_experiments)

    end_time = time()

    print(
        f"Tasa de éxito (probabilidad de elegir al mejor jugador): {success_rate:.4f}")
    print(f"Tiempo de ejecución: {end_time - start_time:.4f} segundos.")
