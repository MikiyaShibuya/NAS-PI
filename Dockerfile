FROM alpine:3.17.2

ARG TZ="UTC"
ARG SMB_USER="dummy"
ARG SMB_PASSWD="notapasswd"
ENV TZ=$TZ

ARG SAMBA_VERSION=4.15.13

COPY ./smb.conf /smb.conf

RUN apk --update --no-cache add \
    bash coreutils samba tzdata \
  && rm -rf /tmp/* \
  && cp /smb.conf /etc/samba/smb.conf \
  && adduser -D ${SMB_USER} \
  && sh -c "(echo ${SMB_PASSWD}; echo ${SMB_PASSWD}) | smbpasswd -a -s -U ${SMB_USER}"

CMD [ "smbd", "-F", "--debug-stdout", "--no-process-group"]
