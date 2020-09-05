# Get OpenNIC root hints
FROM alpine:latest AS hints
RUN apk add --update bind-tools && \
    dig . NS @45.56.115.189 > opennic.root


# Main image
FROM alpine:latest
MAINTAINER Radek Sprta <mail@radeksprta.eu>

LABEL org.label-schema.description = "Unbound DNS server. It can run as resolver or a simple authoritative server."
LABEL org.label-schema.docker.cmd= "docker run --name unbound -d -p 53:53 -p 53:53/udp --restart=unless-stopped rsprta/unbound:latest"
LABEL org.label-schema.name = "unbound"
LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.url= "https://nlnetlabs.nl/projects/unbound/about/"
LABEL org.label-schema.usage= "https://gitlab.com/radek-sprta/docker-unbound/-/blob/master/README.md"
LABEL org.label-schema.vendor= "Radek Sprta"

EXPOSE 53
EXPOSE 53/udp

COPY --from=hints opennic.root /etc/unbound/opennic.root
RUN apk add --update unbound && \
    wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/icann.root && \
    unbound-anchor -a /etc/unbound/trusted-icann.key; true && \
    unbound-anchor -a /etc/unbound/trusted-opennic.key -r /etc/unbound/opennic.root; true

# Configuration
COPY config/access-control.conf /etc/unbound/access-control.conf
COPY config/auth-zones.conf /etc/unbound/auth-zones.conf
COPY config/forward-zones.conf /etc/unbound/forward-zones.conf
COPY config/local-zones.conf /etc/unbound/local-zones.conf
COPY config/unbound.conf /etc/unbound/unbound.conf

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
