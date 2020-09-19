#!/bin/sh

# Start needed services using supervisor
sudo service supervisor start

# Set default ownership for home, ssh keys, web root and mysql (might have been modified from outside)
sudo chown -R docker:docker /home/docker
sudo chmod 0700 ~/.ssh && sudo chmod -f 0600 ~/.ssh/id_rsa || true && sudo chmod -f 0644 ~/.ssh/id_rsa.pub || true 
sudo chown -R docker:docker /home/docker/.ssh
sudo chown -R docker:docker /home/docker/.ssh/config
# Run a new shell
/bin/zsh

# Stop all services
echo Shutting down all services...
sudo supervisorctl stop all
sudo supervisorctl shutdown

# Exit the container
exit