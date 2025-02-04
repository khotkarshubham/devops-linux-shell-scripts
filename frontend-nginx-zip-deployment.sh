#!/bin/bash

# Define variables
DEPLOY_DIR="/var/www/html/yourdirectory"
BUILD_DIR="/home/username/uploaddiretory"
ZIP_FILE="file-name*.zip"

# Remove old files from the deployment directory
echo "Removing old files from $DEPLOY_DIR..."
sudo rm -rfv $DEPLOY_DIR/*

# Change to the build directory
cd $BUILD_DIR || { echo "Failed to change directory to $BUILD_DIR"; exit 1; }

# Unzip the new build to the deployment directory
echo "Unzipping new build to $DEPLOY_DIR..."
sudo unzip $ZIP_FILE -d $DEPLOY_DIR || { echo "Failed to unzip $ZIP_FILE"; exit 1; }

# Remove the zip file
echo "Deleting zip file..."
sudo rm -rfv $ZIP_FILE

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "Deployment completed successfully."
