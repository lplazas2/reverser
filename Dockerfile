# syntax=docker/dockerfile:1
FROM golang:1.21 as build
RUN useradd -u 1001 -m iamuser
ARG OS=linux
ARG GOARCH=amd64
WORKDIR /src
COPY go.mod main.go ./
COPY internal ./internal
RUN go mod download
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH=${GOARCH} go build -o /bin/reverser

FROM scratch
COPY --from=build /bin/reverser /bin/reverser
COPY --from=build /etc/passwd /etc/passwd
USER 1001
CMD ["/bin/reverser"]
