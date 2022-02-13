FROM dart:stable AS build

WORKDIR /app
COPY . .

WORKDIR ./example
RUN dart pub get
RUN dart run dart_web build

FROM alpine:3.14

COPY --from=build /runtime/ /
COPY --from=build /app/example/build/ /app/

CMD ["/app/app"]