FROM golang as builder

WORKDIR /go/src/app
COPY . .

RUN go build .

FROM ubuntu:22.04

COPY --from=builder /go/src/app/smokescreen /usr/local/bin/smokescreen
COPY acl.yaml /etc/smokescreen/acl.yaml

CMD ["smokescreen", "--egress-acl-file", "/etc/smokescreen/acl.yaml"]
