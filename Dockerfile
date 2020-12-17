FROM golang:1.14-alpine AS backend
WORKDIR /src
COPY . ./
# 解决go 时区和https请求证书错误问题
RUN apk update \
    && apk add ca-certificates \
    && update-ca-certificates \
    && apk add tzdata \
    && set -ex \
    && go env -w GO111MODULE=on \
    && go env -w GOPROXY=https://goproxy.cn,direct \
	&& CGO_ENABLED=0 go build -a -ldflags "-w -s" -o ems main.go

FROM alpine:3.12
WORKDIR /app
COPY --from=backend /src/ems /app
COPY ["./bin", "/app/"]
EXPOSE 10280
CMD ["./ems"]
