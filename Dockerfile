FROM aarch64/ubuntu

MAINTAINER Aleksandr Smirnov alex@sander.ee

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    nginx \
    golang \
    ca-certificates \
    wget \
    git-core \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

# Install Forego
RUN GOPATH=/tmp go get -u github.com/jaxer/forego \
    && cp /tmp/bin/forego /usr/local/bin/forego \
    && chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/jaxer/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-arm64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-arm64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-arm64-$DOCKER_GEN_VERSION.tar.gz

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
