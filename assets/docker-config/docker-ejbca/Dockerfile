FROM primekey/ejbca-ce

USER root

COPY utimaco/cs_pkcs11_R3.cfg /etc
COPY utimaco/libcs_pkcs11_R3.so /usr/lib64
COPY utimaco/web.properties /etc/ejbca/conf/

ENV HSM_PKCS11_LIBRARY=/usr/lib64/libcs_pkcs11_R3.so

EXPOSE 8080/tcp
EXPOSE 8443/tcp