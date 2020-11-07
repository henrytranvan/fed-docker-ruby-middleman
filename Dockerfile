# Dockerfile

FROM ruby:2.6.3

LABEL maintainer="Deloitte Digital Team"
LABEL version="1.0.1"
LABEL description="Deloitte base image including Ubuntu, PHP, Apache"

ENV DEBIAN_FRONTEND noninteractive
ENV NODE_VERSION "8.11 8.12"
ENV DEFAULT_NODE_VERSION 8.12


# Add the docker user
ocker
RUN useradd docker && passwd -d docker && adduser docker sudo
RUN mkdir -p $HOME && chown -R docker:docker $HOME

WORKDIR /home/docker/sites

# Install base tools.
RUN apt-get -yqq update && \
    apt-get -yqq install \
        sudo \
        libpq5 \
        libpq-dev \
		apt-utils \
        supervisor \
        openssh-client \
        nano


# Install ssh server.
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ADD ssh keys needed for connections to external servers
RUN mkdir -p $HOME/.ssh
VOLUME [ "$HOME/.ssh" ]
RUN echo "    IdentityFile $HOME/.ssh/id_rsa" >> /etc/ssh/ssh_config


# install nodejs 
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs


# Copy Ruby and Node dependencies
COPY Gemfile Gemfile.lock package.json package-lock.json ./

# Install dependencies
RUN gem install bundler -v 2.1.4
RUN bundle install --without debug

USER root

# Install zsh / OH-MY-ZSH
RUN apt-get -yqq install zsh && git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh

# Add zsh configuration
ADD config/.zshrc $HOME/.zshrc

#add bash_profile
ADD config/.bash_profile $HOME/.bash_profile

# Add bashrc configuration
ADD config/.bashrc $HOME/.bashrc

# Change file owner to docker guys.
RUN chown docker:docker $HOME/.zshrc
RUN chown docker:docker $HOME/.bash_profile

# Add startup script
ADD startup.sh $HOME/startup.sh


# Install Supervisor.
RUN mkdir -p /var/log/supervisor
# Supervisor configuration
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entry point for the container
RUN chown -R docker:docker $HOME && chmod +x $HOME/startup.sh

USER docker
ENV SHELL /bin/zsh
CMD ["/bin/bash", "-c", "$HOME/startup.sh"]

# Expose web root as volume
VOLUME ["/home/docker/sites"]

# Expose some ports to the host system (web server, ssh, Xdebug)
EXPOSE 22 4455