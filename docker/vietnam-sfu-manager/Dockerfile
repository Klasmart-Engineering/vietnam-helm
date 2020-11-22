FROM golang:alpine AS build

WORKDIR /go/src/vietnam-sfu-manager
COPY . .

RUN go build .

FROM alpine:latest

WORKDIR /root
COPY --from=build /go/src/vietnam-sfu-manager/vietnam-sfu-manager .
COPY job.yaml .

CMD [ "./vietnam-sfu-manager" ]


