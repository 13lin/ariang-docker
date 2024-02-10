###################
# Build AriaNg web UI
###################

ARG NODE_VERSION=16

FROM node:${NODE_VERSION}-alpine as ui

ARG ARIANG_VERSION=master

WORKDIR /src

RUN apk update && apk add --no-cache git
RUN git clone --branch ${ARIANG_VERSION} --single-branch https://github.com/mayswind/AriaNg.git .
RUN npm install && \
    npx gulp clean build-bundle


###################
# Build darkhttpd server
###################

FROM alpine AS server

ARG DARKHTTPD_VERSION=master

WORKDIR /src

RUN apk update && apk add --no-cache build-base git
RUN git clone --branch ${DARKHTTPD_VERSION} --single-branch https://github.com/emikulic/darkhttpd.git .
RUN make darkhttpd-static && \
    strip darkhttpd-static


###################
# PRODUCTION
###################

FROM scratch

WORKDIR /var/www/htdocs

COPY --from=ui     /src/dist .
COPY --from=ui     /src/node_modules/font-awesome/fonts/fontawesome-webfont.* fonts/
COPY --from=server /src/darkhttpd-static /darkhttpd

EXPOSE 80
ENTRYPOINT ["/darkhttpd"]
CMD ["."]
