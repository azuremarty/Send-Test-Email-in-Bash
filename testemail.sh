#!/bin/bash

#clear retry queue
/usr/sbin/exim_tidydb -t 1d /var/spool/exim retry > /dev/null
rm -rf /var/spool/exim/db/retry
rm -rf /var/spool/exim/db/retry.lockfile

# Menu to choose sender address
# change to your own desired address
echo "Choose sender address option:"
echo "1. Send as hello@martypete.com"
echo "2. Send as custom sender"
read -p "Enter your choice (1 or 2): " sender_option

# Default sender address
# change to your own desired address
default_sender="hello@martypete.com"

# Custom sender address
custom_sender=""

if [ "$sender_option" == "2" ]; then
    # Prompt for custom sender address
    read -e -p "RFC5321.MailFrom address (Return-Path): " custom_mailfrom
    read -e -p "RFC5322.From address (From): " custom_from
fi

# If using custom sender, set both FROM addresses to custom sender
if [ -n "$custom_mailfrom" ] && [ -n "$custom_from" ]; then
    from_field="$custom_from"
    smtp_mailfrom="$custom_mailfrom"
else
    # Use default sender address
    from_field="$default_sender"
    smtp_mailfrom="$default_sender"
fi

# Prompt for the TO field
read -e -p "Enter RCPT TO address: " to_field

# Prompt for the Subject
read -e -p "Enter the Subject: " subject

# Prompt for the Body (terminate with a line containing only '.')
echo "Enter the Body (terminate with a line containing only '.'): "
body=""
while IFS= read -r line
do
    if [ "$line" = "." ]; then
        break
    fi
    body="$body$line\n"
done

# Construct the email and send it using exim with TLS
echo -e "From: $from_field\nTo: $to_field\nSubject: $subject\n\n$body" | exim -v -i -f "$smtp_mailfrom" -t -tls-on-connect