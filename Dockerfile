FROM alpine
RUN apk add rsync inotify-tools
COPY . /app
ENTRYPOINT [ "sh", "/app/sync.sh" ]
