# Use Debian, because TS doesn't seem to work very will with Alpine.
FROM debian:stretch

ENV LANG C.UTF-8

COPY config.layout /usr/src
RUN	set -ex									\
	&& apt-get update							\
	&& apt-get -y install tar gcc bzip2 libc6-dev linux-libc-dev make curl	\
		libncursesw5-dev openssl libssl1.0-dev zlib1g-dev libpcre3-dev	\
		perl libxml2-dev libcap-dev tcl8.6-dev libhwloc-dev libcap2	\
		libgeoip-dev libmariadbclient-dev-compat libkyotocabinet-dev	\
		libreadline-dev ca-certificates libtcl8.6 libgeoip1		\
		libkyotocabinet16v5 libmariadbclient18 autoconf			\
	&& mkdir -p /usr/src							\
	&& cd /usr/src								\
	&& curl -L https://github.com/apache/trafficserver/archive/7.1.x.tar.gz | gzip -dc | tar xf - \
	&& cd trafficserver-7.1.x						\
	&& cp /usr/src/config.layout .						\
	&& autoreconf -if							\
	&& env LDFLAGS='-Wl,-rpath,/usr/local/lib'				\
		./configure							\
		--with-user=nobody --with-group=nogroup				\
		--enable-wccp --enable-hardening --enable-luajit		\
		--enable-tproxy --enable-experimental-plugins			\
		--enable-layout=Torchbox					\
	&& make -j$(getconf _NPROCESSORS_ONLN)					\
	&& make install								\
	&& apt-get -y purge gcc libc6-dev linux-libc-dev make curl		\
		libncursesw5-dev libssl1.0-dev zlib1g-dev libpcre3-dev		\
		libxml2-dev libcap-dev tcl8.6-dev libhwloc-dev libgeoip-dev	\
		libmariadbclient-dev-compat libkyotocabinet-dev libreadline-dev	\
		libmariadbclient-dev						\
	&& apt-get -y autoremove						\
	&& rm -rf /usr/src /var/cache/apt /var/lib/apt/lists/*

CMD ["/usr/local/bin/traffic_cop", "-o"]
