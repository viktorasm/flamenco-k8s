FROM --platform=linux/amd64 flamenco-blender-base


WORKDIR /server
COPY ./flamenco-manager /server/
RUN chmod +x /server/flamenco-manager

CMD ["/server/flamenco-manager", "--debug"]
