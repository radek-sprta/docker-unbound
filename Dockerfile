# Get OpenNIC root hints
FROM alpine:latest AS hints
RUN apk add --update bind-tools && \
    dig . NS @45.56.115.189 > opennic.root


# Main image
FROM alpine:latest
MAINTAINER Radek Sprta <mail@radeksprta.eu>

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
