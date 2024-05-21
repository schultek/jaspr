# We need a docker image that contains flutter for our flutter plugin support.
FROM ghcr.io/cirruslabs/flutter:stable as build

RUN touch /.dockerenv

RUN dart pub global activate jaspr_cli

WORKDIR /app
COPY . .

# Resolve app dependencies.
RUN rm -f pubspec_overrides.yaml
RUN dart pub get

# Build project
RUN dart pub global run jaspr_cli:jaspr build --verbose

# This is additionally needed for the runtime libs.
FROM dart:stable as dart

FROM scratch

COPY --from=dart /runtime/ /
COPY --from=build /app/build/jaspr/ /app/
COPY --from=build /app/service-account.json /app/

WORKDIR /app

# Start server.
EXPOSE 8080
CMD ["./app"]
