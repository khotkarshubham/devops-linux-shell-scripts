#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Ensure the script stops if any command in a pipeline fails

# Define variables
BACKEND_DIR="/home/username/Backend/servicedirectory"
NEWBUILD_DIR="/home/username/uploaddirectory"
TAR_FILE="filename*.tgz"
PACKAGE_DIR="$NEWBUILD_DIR/package"
SERVICE_NAME="servicename"

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

echo "Navigating to $BACKEND_DIR..."
cd "$BACKEND_DIR"

echo "Removing old files and directories..."
sudo rm -rfv README.md docs logs package-lock.json package.json server.js src swagger-apis.yaml swagger.js
check_success "Removing old files and directories"

echo "Navigating to $NEWBUILD_DIR..."
cd "$NEWBUILD_DIR"

echo "Extracting tar.gz file..."
if [ ! -f "$TAR_FILE" ]; then
    echo "Error: $TAR_FILE not found."
    exit 1
fi
sudo tar -zxvf $TAR_FILE
check_success "Extracting tar.gz file"

echo "Copying new files..."
sudo cp -r $PACKAGE_DIR/* "$BACKEND_DIR/"
check_success "Copying new files"

# Check if the PM2 process exists, if not, install node modules and start the service
if ! sudo pm2 list | grep -q "$SERVICE_NAME"; then
    echo "PM2 process '$SERVICE_NAME' does not exist. Installing node modules and starting a new one..."
    
    # Navigate to the backend directory and install node modules
    cd "$BACKEND_DIR"
    sudo npm install
    check_success "Installing node modules"
    
    # Start the PM2 process
    sudo pm2 start "$BACKEND_DIR/server.js" --name "$SERVICE_NAME"
    check_success "Starting PM2 process"
else
    echo "PM2 process '$SERVICE_NAME' exists. Restarting..."
    sudo pm2 restart "$SERVICE_NAME"
    check_success "Restarting PM2 process"
fi

echo "Reloading Nginx..."
sudo systemctl restart nginx
check_success "Restarting Nginx"

echo "Saving PM2 process list..."
sudo pm2 save
check_success "Saving PM2 process list"

echo "Cleaning up..."
# Delete the tar file
sudo rm -f $TAR_FILE
check_success "Deleting tar file"

# Delete the package folder
sudo rm -rf $PACKAGE_DIR
check_success "Deleting package folder"

echo "Deployment script completed successfully."
