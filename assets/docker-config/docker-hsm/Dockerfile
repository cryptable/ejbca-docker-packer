FROM ubuntu
MAINTAINER ddt-tdd <dtillemans@gmail.com>

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y libc6-i386 && \
    apt-get install -y lib32gcc1

ADD p11/cs_pkcs11_R3.cfg /etc
ADD p11/libcs_pkcs11_R3.so /usr/local/lib
ADD sim5_linux /opt/sim5_linux
ADD Administration/csadm /opt/cs2/bin/
ADD admin_key/ADMIN.key /root

RUN ln -s /opt/cs2/bin/csadm /usr/bin/csadm
RUN ln -s /opt/sim5_linux/bin/cs_sim_stop.sh /usr/bin/cs_sim_stop.sh

ARG volname="/hsm"
ARG port=3001

VOLUME ["${volname}"]
ENV SDK_INSTANCE_PATH=${volname} SDK_PORT=${port}

EXPOSE ${port}

WORKDIR /root
ENTRYPOINT [ "/opt/sim5_linux/bin/cs_docker.sh", "1" ]
