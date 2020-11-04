# unbound

## Quick reference
-	**Maintained by**: [Radek Sprta](https://gitlab.com/radek-sprta)
-	**Where to get help**: [Repository Issues](https://gitlab.com/radek-sprta/docker-unbound/-/issues)

## Description
This container is to designed to run [Unbound][unbound] DNS server. It can run as resolver or a simple
authoritative server.

## Usage
The simplest way to run Unbound is the following command:

```bash
docker run --name unbound -d -p 53:53 -p 53:53/udp --restart=unless-stopped rsprta/unbound:latest
```

Or using `docker-compose.yml`:

```yaml
version: '3'
services:
  dns:
    container_name: unbound
    image: rsprta/unbound
    ports:
      - "53:53"
      - "53:53/udp"
    volumes:
      - "unbound.conf:/etc/unbound/unbound.conf:ro"
    restart: unless-stopped
```

However, in default configuration, it is not too useful. But you can overwrite some key options using
volumes and environmental variables.

### Resolving local domains
If you want Unbound to resolve a local domain (such as `.local` or `.lan`), you can achieve that by
providing `local-zones.conf` file. The contents should look like this:

```yaml
        local-data: "desktop.lan. A 192.168.0.100"
        local-data: "laptop.lan. A 192.168.0.101"
        local-data: "nas.lan. A 192.168.0.102"

    	local-data-ptr: "192.168.0.100 desktop.local."
    	local-data-ptr: "192.168.0.101 laptop.local."
    	local-data-ptr: "192.168.0.102 nas.local."
```

Careful, you need to preserve the leading whitespace!

Afterwards, mount the file as volume:

```yaml
volumes:
  - "local-zones.conf:/etc/unbound/local-zones.conf:ro"
```

### DNS forwarder
To make Unbound forward non-local zone to a recursive DNS resolver, you need to provide a `forward-zones.conf`
file. If you want to forward all zones, the file might look like this:

```yaml
forward-zone:
      name: "."

      # OpenNIC
      forward-addr: 78.47.243.3@853#ns21.de.dns.opennic.glue
      forward-addr: 62.210.177.189@853#ns3.fr.dns.opennic.glue

      # Quad9
      forward-addr: 9.9.9.9@853#dns.quad9.net
      forward-addr: 149.112.112.112@853#dns.quad9.net
```

Mount it as volume:

```yaml
volumes:
  - "forward-zones.conf:/etc/unbound/forward-zones.conf:ro"
```

### Simple authoritative DNS
Unbound can even act as a very simple authoritative server. Again, you can defines this behavior in
`auth-zones.conf` file.

```yaml
auth-zone:
      name: "example.org"
      for-downstream: yes
      for-upstream: yes
      zonefile: "example.org.zone"
```

And mount both the configuration and the zone file:
```yaml
volumes:
  - "auth-zones.conf:/etc/unbound/auth-zones.conf:ro"
  - "example.org.zone:/etc/unbound/example.org.zone:ro"
```

### Overwriting access control list
By default, the container answers queries coming from any IP address. If you want to change that, provide
`access-control.conf` file. It might look like this:

```yaml
        access-control: 192.168.0.0/24 allow
        access-control: 10.0.0.0/8 refuse
```

Do not leave out the leading whitespace. Mount the file like this:

```yaml
volumes:
  - "access-control.conf:/etc/unbound/access-control.conf:ro"
```

## Environment variables
You can adjust the container's behavior by declaring the following environment variables:

### CACHE_MIN_TTL
Minimal TTL to use for caching. Defaults to 0

### DO_IPV6
Use IPv6. Defaults to yes.

### DO_IPV4
Use IPv4. Defaults to yes.

### DO_UDP
Use UDP. Defaults to yes.

### DO_TCP
Use TCP. Default to yes.

### RATELIMIT
Number of requests per second that an IP address is allowed to perform. Defaults to 0 (disabled).

### ROOT_HINTS
Which root servers to use. Defaults to ICANN root servers. Alternatively, use opennic.

### SO_REUSEPORT
Reuse ports. Defaults to yes.

### SERVE_EXPIRED
Serve expired records from cache while performing a DNS lookup. Defaults to yes.

### STATISTICS_INTERVAL
Statistics gathering interval in seconds. Defaults to 0 (disabled).

### STATISTICS_CUMULATIVE
Print cumulative statistics. Defaults to no.

### EXTENDED_STATISTICS
Print extended statistics. Defaults to no.

### VERBOSITY
Verbosity level. Defaults to 0 (least verbose).

## Contributing
For information on how to contribute to the project, please check the [Contributor's Guide][contributing].

## Contact
[mail@radeksprta.eu](mailto:mail@radeksprta.eu)
[incoming+radek-sprta/docker-unbound@gitlab.com](incoming+radek-sprta/docker-unbound@gitlab.com)

## License
GNU General Public License v3

## Credits
The container was heavily inspired by:

- [mvance/unbound](https://hub.docker.com/r/mvance/unbound)
- [secns/unbound](https://hub.docker.com/r/secns/unbound)

Multi-arch builds are copied from:
[klutchell/unbound](https://hub.docker.com/r/klutchell/unbound)

This package was created with [Cookiecutter][cookiecutter].

[contributing]: https://gitlab.com/radek-sprta/docker-unbound/blob/master/CONTRIBUTING.md
[cookiecutter]: https://github.com/audreyr/cookiecutter
[unbound]: https://unbound.net
