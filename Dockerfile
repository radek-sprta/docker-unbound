# Get OpenNIC root hints
FROM alpine:latest AS hints
RUN apk add --update bind-tools && \
    dig . NS @45.56.115.189 > opennic.root


# Main image
FROM alpine:latest
MAINTAINER Radek Sprta <mail@radeksprta.eu>

EXPOSE 53
EXPOSE 53/udp

RUN apk add --update unbound

# Configuration
COPY auth-zones.conf /etc/unbound/auth-zones.conf
COPY forward-zones.conf /etc/unbound/forward-zones.conf
COPY local-zones.conf /etc/unbound/local-zones.conf
COPY --from=hints opennic.root /usr/share/dns-root-hints/opennic.root
COPY unbound.conf /etc/unbound/unbound.conf

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
