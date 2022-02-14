FROM dart:stable AS build

WORKDIR /app
COPY . .

WORKDIR /app/demo

RUN dart pub get
RUN dart run jaspr build

FROM alpine:3.14

COPY --from=build /runtime/ /
COPY --from=build /app/demo/build/ /app/

CMD ["/app/app"]