FROM golang:1.24 as builder

ARG TARGETOS
ARG TARGETPLATFORM
ARG TARGETARCH

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source
COPY main.go main.go
COPY plugin/ plugin/
COPY vendor/ vendor/

# Build
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -mod=vendor -a -o coredns main.go


FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /

COPY --from=builder /workspace/coredns .
COPY Corefile Corefile

USER nonroot:nonroot

EXPOSE 1053 1053/udp
ENTRYPOINT ["/coredns"]
