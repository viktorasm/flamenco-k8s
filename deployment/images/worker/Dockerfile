# Start by specifying a base image
FROM --platform=linux/amd64 flamenco-blender-base


WORKDIR /worker
COPY ./bin/flamenco-worker /worker/
COPY ./entrypoint.sh /worker/entrypoint.sh
RUN chmod +x /worker/flamenco-worker
RUN chmod +x /worker/entrypoint.sh

#CMD ["/worker/flamenco-worker"]
ENTRYPOINT ["./entrypoint.sh"]