
FROM centos:7.6.1810
RUN yum --disableplugin=fastestmirror -y install openssl && rm -rf /var/cache/yum/*

####
ARG  USER
ARG  GROUP
ARG  UID
ARG  GID
## must use ; here to ignore user exist status code
RUN  groupadd -f -g ${GID} ${GROUP};useradd -d /home/${USER} -g ${GROUP} -K UID_MAX=${UID} -K UID_MIN=${UID} ${USER};echo
USER ${USER}
####
