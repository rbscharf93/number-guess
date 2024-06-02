#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# Dump: pg_dump -cC --inserts -U freecodecamp number_guess > number_guess.sql
# Restore: psql -U postgres < number_guess.sql

RAND=$RANDOM
RAND1000=$(( RAND % 1000 + 1 ))
echo $RAND1000

echo -e "\nEnter your username:\n"
read USERNAME

USER_ID=$($PSQL "
  SELECT user_id
  FROM users
  WHERE username = '$USERNAME';
")
if [[ -z $USER_ID ]]
then
  USER_RESULT=$($PSQL "
    INSERT INTO users(username)
    VALUES('$USERNAME');
  ")
  USER_ID=$($PSQL "
    SELECT user_id
    FROM users
    WHERE username = '$USERNAME';
  ")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  COUNT=$($PSQL "
    SELECT COUNT(*)
    FROM games
    WHERE user_id = $USER_ID;
  ")
  BEST=$($PSQL "
    SELECT MIN(guesses)
    FROM games
    WHERE user_id = $USER_ID;
  ")
  echo -e "\nWelcome back, $USERNAME! You have played $COUNT games, and your best game took $BEST guesses."
fi

echo -e "Guess the secret number between 1 and 1000:\n"

COUNT=1
while true
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:\n"
    continue
  fi
  if [[ $GUESS -lt $RAND1000 ]]
  then
    COMPARE="higher"
  elif [[ $GUESS -gt $RAND1000 ]]
  then
    COMPARE="lower"
  else
    break
  fi
  echo -e "\nIt's $COMPARE than that, guess again:\n"
  COUNT=$(( $COUNT + 1 ))
done

GAME_RESULT=$($PSQL "
  INSERT INTO games(guesses, user_id)
  VALUES($COUNT, $USER_ID);
")
echo -e "\nYou guessed it in $COUNT tries. The secret number was $RAND1000. Nice job!"
