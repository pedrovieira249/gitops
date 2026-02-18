FROM golang:1.25.6 AS build
WORKDIR /app
COPY . .
RUN go build -o server .

RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM scratch
WORKDIR /app
COPY --from=build /app/server .
ENTRYPOINT [ "./server" ]