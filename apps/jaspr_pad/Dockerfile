# Use latest stable channel SDK.
FROM dart:stable as build

# Resolve app dependencies.
WORKDIR /app
COPY . /app
WORKDIR /app

RUN dart pub global activate jaspr_cli 0.21.0
RUN dart pub get

RUN jaspr build

FROM dart:stable

COPY --from=build /app/build/jaspr/ /app/
COPY --from=build /app/serviceAccountKey.json /app/
COPY --from=build /app/templates /app/templates
COPY --from=build /app/samples /app/samples

WORKDIR /app/templates/jaspr_basic
RUN dart pub get

WORKDIR /app

# Start server.
EXPOSE 8080

ENV DART_SDK_PATH=/usr/lib/dart

CMD ["./app"]
