FROM phusion/baseimage:0.11
ARG DEBIAN_FRONTEND=noninteractive

ENV LITECORE_NODE_VERSION 3.1.11
ENV LITECORE_NODE /usr/local/bin/litecore-node
ENV LITECORE_PATH /opt/litecore
ENV DAEMON_USER litecore

# Update & install dependencies and do cleanup
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        nodejs \
        npm \
        inetutils-ping \
        build-essential \
        libzmq3-dev \
        curl \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add LITECORE system user
RUN useradd -m -r -d $LITECORE_PATH -s /bin/bash $DAEMON_USER

# Install node
RUN npm install --unsafe-perm=true -g litecore-node@$LITECORE_NODE_VERSION

# Switch user for setting up dashcore services
USER $DAEMON_USER
RUN cd ~ && \
    litecore-node create mynode && \
    cd mynode && \
    $LITECORE_NODE install insight-lite-api && \
    $LITECORE_NODE install insight-lite-ui

USER root
# Add our startup script
RUN mkdir /etc/service/litecore-node
COPY litecore-node.sh /etc/service/litecore-node/run
RUN chmod +x /etc/service/litecore-node/run

EXPOSE 3001
VOLUME ["$LITECORE_PATH/mynode/data/"]
CMD ["/sbin/my_init"]
