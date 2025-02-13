#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~ Welcome to the Salon Appointment Scheduler ~~~\n"

# Display available services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME; do
  echo "$SERVICE_ID) $NAME"
done

# Function to handle service selection
SELECT_SERVICE() {
  read SERVICE_ID_SELECTED
  SERVICE_EXISTS=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_EXISTS ]]; then
    echo -e "\nInvalid selection. Please choose a valid service:\n"
    echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME; do
      echo "$SERVICE_ID) $NAME"
    done
    SELECT_SERVICE
  fi
}

# Prompt for service selection
echo -e "\nPlease select a service by entering the corresponding number:"
SELECT_SERVICE

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nYou are a new customer. Please enter your name:"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Prompt for appointment time
echo -e "\nEnter your preferred appointment time:"
read SERVICE_TIME

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Output confirmation message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
