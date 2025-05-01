# Use latest stable channel SDK.
FROM dart:latest AS build

# Resolve app dependencies.
WORKDIR /app

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY packages/jaspr packages/jaspr
COPY packages/jaspr_og packages/jaspr_og
COPY apps/pub_social apps/pub_social

FROM dart:latest

COPY --from=build /app /app

WORKDIR /app/apps/pub_social

RUN dart pub get
RUN dart pub global activate native_doctor
RUN dart pub global run native_doctor -y
RUN apt-get update
RUN apt install build-essential -y
RUN dart --enable-experiment=native-assets run bin/init.dart

# Start server.
EXPOSE 8080
CMD dart --enable-experiment=native-assets run bin/server.dart
