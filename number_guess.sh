#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY() {

  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "select u_id from users where name = '$USERNAME'")

  if [[ $USER_ID ]]; then
    GAMES_PLAYED=$($PSQL "select count(u_id) from games where u_id = '$USER_ID'")

    BEST_GUESS=$($PSQL "select min(guesses) from games where u_id = '$USER_ID'")

    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."

    INSERTED_TO_USERS=$($PSQL "insert into users(name) values('$USERNAME')")
    USER_ID=$($PSQL "select u_id from users where name = '$USERNAME'")
  fi

  GAME
}

GAME() {
  SECRET=$((1 + $RANDOM % 1000))

  TRIES=0

  GUESSED=0
  echo -e "Guess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "That is not an integer, guess again:"
    elif [[ $SECRET = $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
      INSERTED_TO_GAMES=$($PSQL "insert into games(u_id, guesses) values($USER_ID, $TRIES)")
      GUESSED=1
    elif [[ $SECRET -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "It's higher than that, guess again:"
    else
      TRIES=$(($TRIES + 1))
      echo -e "It's lower than that, guess again:"
    fi
  done
}

DISPLAY
