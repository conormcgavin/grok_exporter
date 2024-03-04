FROM ubuntu:latest as build

ARG version=0.0.0
ARG created=0
ARG PACKAGE="github.com/conormcgavin/grok_exporter"

COPY . .

RUN apt-get update && apt-get install -y \
    git \
    libonig-dev \
    golang-go

# build go files
RUN export CGO_LDFLAGS=/usr/local/lib/libonig.a
RUN export GO111MODULE=off
RUN go build -ldflags "-X ${PACKAGE}/core.Version=${version} -X ${PACKAGE}/core.BuildTime=${created}" -o grok_exporter .

# copy to /grok directory
RUN mkdir /grok && cp grok_exporter /grok

# setup the link to the config file
RUN mkdir -p /etc/grok_exporter
RUN ln -sf /etc/grok_exporter/config.yml /grok/

# change workdir to new /grok directory
WORKDIR /grok

# run with config file
CMD ["./grok_exporter", "-config", "/grok/config.yml"]
