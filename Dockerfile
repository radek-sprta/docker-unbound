# Get OpenNIC root hints
FROM alpine:3 AS hints
RUN apk add --no-cache --update bind-tools && \
    dig . NS @168.119.153.26 > opennic.root

# Main image
FROM alpine:3

LABEL maintainer="Radek Sprta <mail@radeksprta.eu>"
LABEL org.opencontainers.image.authors="Radek Sprta <mail@radeksprta.eu>"
LABEL org.opencontainers.image.description="Unbound DNS server. It can run as resolver or a simple authoritative server."
LABEL org.opencontainers.image.documentation="https://radek-sprta.gitlab.io/docker-unbound"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.source="https://gitlab.com/radek-sprta/docker-unbound"
LABEL org.opencontainers.image.title="rsprta/unbound"
LABEL org.opencontainers.image.url="https://gitlab.com/radek-sprta/docker-unbound"

EXPOSE 53
EXPOSE 53/udp

HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=10s \
    CMD nslookup duckduckgo.com 127.0.0.1 || exit 1

COPY --from=hints opennic.root /etc/unbound/opennic.root
RUN apk add --no-cache --update unbound && \
    wget ftp://ftp.internic.net/domain/named.cache -O /etc/unbound/icann.root && \
    unbound-anchor -a /etc/unbound/trusted-icann.key; true && \
    unbound-anchor -a /etc/unbound/trusted-opennic.key -r /etc/unbound/opennic.root; true && \
    chown -R unbound:unbound /etc/unbound

# Configuration
COPY config/access-control.conf /etc/unbound/access-control.conf
COPY config/auth-zones.conf /etc/unbound/auth-zones.conf
COPY config/forward-zones.conf /etc/unbound/forward-zones.conf
COPY config/local-zones.conf /etc/unbound/local-zones.conf
COPY config/unbound.conf /etc/unbound/unbound.conf

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
