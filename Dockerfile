FROM alpine:3.6 AS build

RUN apk --update add git postgresql-dev build-base c-ares-dev mosquitto-dev=1.4.12-r0

RUN mkdir /build \
	&& cd /build \
	&& git clone https://github.com/jpmens/mosquitto-auth-plug.git \
	&& cd mosquitto-auth-plug \
	&& cp config.mk.in config.mk \
	&& sed -i 's/BACKEND_MYSQL ?= yes/BACKEND_MYSQL ?= no/' config.mk \
	&& sed -i 's/BACKEND_POSTGRES ?= no/BACKEND_POSTGRES ?= yes/' config.mk \
	&& sed -i 's/BACKEND_FILES ?= no/BACKEND_FILES ?= yes/' config.mk \
	&& sed -i 's/CFG_CFLAGS =/CFG_CFLAGS = -DRAW_SALT/' config.mk \
	&& make

FROM eclipse-mosquitto:1.4.12

RUN apk --update add postgresql-dev mosquitto-dev=1.4.12-r0 \
	&& rm -rf /var/cache/apk/*

COPY --from=build /build/mosquitto-auth-plug/auth-plug.so /mosquitto/plugins/
COPY --from=build /build/mosquitto-auth-plug/np /usr/local/bin/
