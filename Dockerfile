FROM ubuntu:latest as build

ARG version=0.0.0
ARG created=0
ARG PACKAGE="github.com/conormcgavin/grok_exporter"

COPY . .

RUN apt-get update && apt-get install -y \
    git \
    libonig-dev \
    golang-go

RUN go version

# build go files
RUN export CGO_LDFLAGS=/usr/local/lib/libonig.a
RUN export GO111MODULE=off
RUN go build -ldflags "-X ${PACKAGE}/core.Version=${version} -X ${PACKAGE}/core.BuildTime=${created}" -o grok_exporter .


RUN mkdir /grok && cp grok_exporter /grok
RUN cd logstash-patterns-core && git submodule update && cd .. && cp logstash-patterns-core /grok/patterns
RUN mkdir -p /etc/grok_exporter

# use a safer base
FROM gcr.io/distroless/static:nonroot as run

# copy stuff over
COPY --from=build /grok /
COPY --from=build /etc/grok_exporter /etc/grok_exporter

WORKDIR /

# run with config file
CMD ["/grok_exporter", "-config", "/etc/grok_exporter/config.yml"]

