# syntax=docker/dockerfile:1
FROM golang:1.21
ARG OS=linux
ARG GOARCH=arm64
WORKDIR /src
COPY go.mod main.go ./
COPY internal ./internal
RUN go mod download
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH={GOARCH} go build -o /bin/reverser

FROM scratch
ARG PORT=8080
EXPOSE $PORT
COPY --from=0 /bin/reverser /bin/reverser
CMD ["/bin/reverser"]
