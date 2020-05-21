FROM cm2network/steamcmd AS build-env

RUN ./steamcmd.sh \
    +exit && \
    ./steamcmd.sh \
    +login anonymous \
    +force_install_dir /home/steam/avorion \
    +app_update 565060 validate \
    +exit

FROM ubuntu:18.04
LABEL maintainer="b.pedini@bjphoster.com"

EXPOSE 27000/tcp
EXPOSE 27000/udp
EXPOSE 27003/udp
EXPOSE 27020/udp
EXPOSE 27021/udp

COPY --from=build-env /home/steam/avorion /opt/avorion

RUN apt update && \
    apt install -y \
    openssl && \
    apt install \
    --reinstall \
    ca-certificates && \
    apt clean all && \
    groupadd \
    --gid 10000 \
    avorion && \
    useradd \
    --home-dir /opt/avorion \
    --comment "Avorion Server" \
    --gid avorion \
    --no-create-home \
    --no-user-group \
    --uid 10000 \
    --shell /bin/bash \
    avorion && \
    mkdir -p \
    /var/avorion/galaxies && \
    chown -R \
    avorion:avorion \
    /opt/avorion \
    /var/avorion


USER avorion
VOLUME /var/avorion
CMD [ "/opt/avorion/server.sh", "--public", "1", "--use-steam-networking", "1", "--datapath", "/var/avorion/galaxies" ]
