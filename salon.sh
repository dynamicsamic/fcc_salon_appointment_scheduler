#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN() {
  # greet the customer
  echo -e "\nWelcome to My Salon, how can I help you?\n"

  # show main menu
  MAIN_MENU

}

MAIN_MENU() {
  # check call argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  SELECT_SERVICE
}

SELECT_SERVICE() {
  # read user input into var
  read SERVICE_ID_SELECTED
  # query services table by entered id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if no service exists
  if [[ -z $SERVICE_NAME ]]
  then
  # return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
 
    # query db for customer name
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # if customer does not exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # insert it into the table
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
      
      # get customer id from insert query output
      CUSTOMER_ID=$(echo $NEW_CUSTOMER | grep -Eo '^[0-9]+')
    else
      # if customer exists get their name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # ask for the appointment time 
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # insert new row in the appointments table
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN
