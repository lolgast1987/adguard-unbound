FROM alpine

WORKDIR /var/run/unbound

RUN apk add --no-cache \
	ca-certificates \
	unbound

RUN wget https://www.internic.net/domain/named.root -qO- >> /etc/unbound/root.hints

COPY files/unbound.conf /opt/unbound/unbound.conf

WORKDIR /opt

RUN wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz >/dev/null 2>&1 \
	&& tar xf AdGuardHome_linux_amd64.tar.gz AdGuardHome/AdGuardHome

RUN /bin/ash ./AdGuardHome \
	&& mkdir -p /opt/adguardhome/conf /opt/adguardhome/work \
	&& chown -R nobody: /opt/adguardhome \
	&& setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' /opt/AdGuardHome/AdGuardHome \
	&& rm AdGuardHome_linux_amd64.tar.gz \
	&& rm -rf /tmp/* /var/cache/apk/* 

COPY files/entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

WORKDIR /opt/adguardhome/work

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work", "/opt/unbound"]

EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 853/tcp 3000/tcp 5053/udp 5053/tcp

CMD ["/opt/entrypoint.sh"]