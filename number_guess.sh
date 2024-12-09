#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read username

if ! [[ -z $username ]]
then
  # Buscar username
  FIND_USERNAME=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$username'")
  if [[ -z $FIND_USERNAME ]]
  then
    $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$username', 0, 0)" > /dev/null
    echo "Welcome, $username! It looks like this is your first time here."
  else
    IFS="|" read -r NAME GAMES_PLAYED BEST_GAME <<< "$FIND_USERNAME"
    if [[ $GAMES_PLAYED -eq 0 ]]
    then
      echo "Welcome, $NAME! It looks like this is your first time here."
    else
      echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
  fi

  # Generar número aleatorio
  RANDOM_NUMBER=$((RANDOM % 1000 + 1))
  echo -e "\nGuess the secret number between 1 and 1000:"

  # Inicializar variables
  ATTEMPTS=0
  GUESSED=false

  while [[ $GUESSED == false ]]
  do
    read GUESS
    # Verificar si es un número
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    fi
    ((ATTEMPTS++))

    # Comparar número
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      # Número correcto
      GUESSED=true
      echo -e "You guessed it in $ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"

      # Actualizar games_played
      $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$username'" > /dev/null

      # Actualizar best_game
      if [[ -z $BEST_GAME || $ATTEMPTS -lt $BEST_GAME ]]
      then
        $PSQL "UPDATE users SET best_game = $ATTEMPTS WHERE username = '$username'" > /dev/null
      fi

      # Salir del programa
      exit 0
    fi
  done
else
  echo "Error: Username cannot be empty."
  exit 1
fi
