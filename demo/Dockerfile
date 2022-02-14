FROM dart:stable AS build

WORKDIR /app
COPY . .

RUN dart pub get
RUN dart run jaspr build

FROM alpine:3.14

COPY --from=build /runtime/ /
COPY --from=build /app/build/ /app/

CMD ["/app/app"]