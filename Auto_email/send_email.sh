#!/bin/bash

recipient_email="RECIPIENT_EMAIL@gmail.com"
error_email="EMAIL_FOR_ERRORS@gmail.com"
log_file="/home/user/log.txt"

# Function to calculate the month and day of the month for today
month_day_today() {
    date +%m%d
}

# Calculate and display the day number for today
day_number=$(month_day_today)
log_entry="DayNumber:$day_number"

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1

# Search for the line containing the given number
while IFS= read -r line; do
    if [[ $line == *"$day_number"* ]]; then
        # Extract the message after the number
        message=${line#*$day_number}
        # Remove leading spaces from the message
        message=$(echo "$message" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\n')
        
        if [ -z "$message" ]; then
            # If message is blank, send an error email
            echo "FAILED, DAY $day_number RECIPIENT (hidden) MESSAGE:$message " | mail "$error_email"
            echo "FAILED, DAY $day_number RECIPIENT $recipient_email MESSAGE:$message " | tee -a $log_file
            exit 1
        else
            echo "$message" | mail "$recipient_email"
            echo "SUCCESSFUL, DAY $day_number RECIPIENT $recipient_email MESSAGE:$message " | tee -a $log_file
            exit 0
        fi
        
    fi
done < "$filename"

exit 1
