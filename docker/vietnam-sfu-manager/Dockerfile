FROM golang:alpine AS build

RUN apk update && apk add upx

WORKDIR /go/src/vietnam-sfu-manager
COPY . .

RUN CGO_ENABLED=0 go build -ldflags="-s" .
RUN upx -9 -k vietnam-sfu-manager

FROM alpine:latest

WORKDIR /root
COPY --from=build /go/src/vietnam-sfu-manager/vietnam-sfu-manager .
COPY job.yaml .

CMD [ "./vietnam-sfu-manager" ]


