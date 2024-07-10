#!/bin/bash

# Function to check if mailutils is installed
check_mailutils() {
    if ! command -v mail &> /dev/null; then
        echo "mailutils is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y mailutils
    fi
}

# Function to check if ssmtp is installed
check_ssmtp() {
    if ! command -v ssmtp &> /dev/null; then
        echo "ssmtp is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y ssmtp
    fi
}

# Prompt for username and email
read -p "Enter the username: " USERNAME
read -p "Enter the email address: " EMAIL
read -p "Add user to docker group? (y/n): " ADD_TO_DOCKER_GROUP

# Generate a random password
PASSWORD=$(openssl rand -base64 12)

# Create the user and set the password
sudo useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Display the password
echo "User $USERNAME created with password: $PASSWORD"

# Add user to docker group if requested
if [ "$ADD_TO_DOCKER_GROUP" == "y" ]; then
    sudo usermod -aG docker "$USERNAME"
    echo "User $USERNAME added to the docker group"
fi

# Check and install ssmtp if necessary
check_ssmtp

# Send the password to the user's email using ssmtp
echo -e "To: $EMAIL\nSubject: Account Created\n\nYour account has been created. Username: $USERNAME, Password: $PASSWORD" | ssmtp $EMAIL

echo "Password has been emailed to $EMAIL"
