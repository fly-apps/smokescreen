FROM golang

RUN go get github.com/stripe/smokescreen

RUN echo $GOPATH/bin/smokescreen

FROM ubuntu:18.04

COPY --from=0 /go/bin/smokescreen /usr/local/bin/smokescreen

CMD ["smokescreen"]