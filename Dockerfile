# ------------------------------------------------------------------------------
# Pull base image
FROM debian:wheezy-slim
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Install base and clean up when done
RUN apt-get update && apt-get install -y --no-install-recommends locales \
build-essential g++ curl git ca-certificates python2.7-minimal supervisor && \
apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Configure locale so that tmux works properly
RUN sed -e 's/# en_US.UTF-8/en_US.UTF-8/' -i /etc/locale.gen && locale-gen

# ------------------------------------------------------------------------------
# Prepare node for Cloud9 install scripts
RUN mkdir /root/.c9 && \
curl -s https://nodejs.org/dist/latest-v0.10.x/node-v0.10.48-linux-x64.tar.xz \
-o /root/.c9/node.tar.xz && tar xf /root/.c9/node.tar.xz -C /root/.c9/ && \
mv /root/.c9/node-* /root/.c9/node && rm /root/.c9/node.tar.xz

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /c9 && \
cd /c9 && ./scripts/install-sdk.sh && mkdir /c9ws /var/log/supervisor

# ------------------------------------------------------------------------------
# Add supervisord conf
ADD supervisord.conf /etc/

# ------------------------------------------------------------------------------
# Add volumes
VOLUME /c9ws

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
