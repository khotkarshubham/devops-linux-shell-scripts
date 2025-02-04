#!/bin/bash

# Define variables
DEPLOY_DIR="/var/www/html/yourdirectory"
BUILD_DIR="/home/username/newbuild"
BACKUP_DIR="/home/username/Backup-Builds/yourdirectory"
ZIP_FILE="file-name*.tgz"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/yourdirectory_backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup existing build
if [ "$(ls -A $DEPLOY_DIR)" ]; then
    echo "Backing up existing build to $BACKUP_FILE..."
    sudo tar -czvf "$BACKUP_FILE" -C "$DEPLOY_DIR" . || { echo "Backup failed"; exit 1; }
else
    echo "No existing files to backup."
fi

# Remove old files from the deployment directory
echo "Removing old files from $DEPLOY_DIR..."
sudo rm -rfv $DEPLOY_DIR/*

# Change to the build directory
cd $BUILD_DIR || { echo "Failed to change directory to $BUILD_DIR"; exit 1; }

# Unzip the new build
echo "Unzipping new build..."
sudo tar -xvzf $ZIP_FILE -C $DEPLOY_DIR || { echo "Failed to unzip $ZIP_FILE"; exit 1; }

# Clean up the build directory
echo "Cleaning up..."
sudo rm -rfv $ZIP_FILE

# Nginx Restart
echo "Restarting Nginx"
sudo systemctl restart nginx

echo "Deployment completed successfully."
