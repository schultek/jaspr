# Use latest stable channel SDK.
FROM dart:stable as build

# Resolve app dependencies.
WORKDIR /app
COPY /apps/jaspr_pad /app/apps/jaspr_pad
WORKDIR /app/apps/jaspr_pad
RUN rm pubspec_overrides.yaml
RUN dart pub get
RUN dart pub global activate jaspr_cli
RUN jaspr build

FROM dart:stable

COPY --from=build /app/apps/jaspr_pad/build/jaspr/ /app/apps/jaspr_pad/
COPY --from=build /app/apps/jaspr_pad/serviceAccountKey.json /app/apps/jaspr_pad/
COPY --from=build /app/apps/jaspr_pad/templates /app/apps/jaspr_pad/templates
COPY --from=build /app/apps/jaspr_pad/samples /app/apps/jaspr_pad/samples

WORKDIR /app/apps/jaspr_pad/templates/jaspr_basic
RUN dart pub get

WORKDIR /app/apps/jaspr_pad

# Start server.
EXPOSE 8080

ENV DART_SDK_PATH=/usr/lib/dart

CMD ["./app"]
