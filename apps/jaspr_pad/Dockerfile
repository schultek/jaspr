# Use latest stable channel SDK.
FROM dart:stable as build

# Resolve app dependencies.
WORKDIR /app
COPY . .
WORKDIR /app/apps/jaspr_pad
RUN dart pub get
RUN jaspr build

FROM dart:stable

COPY --from=build /runtime/ /
COPY --from=build /app/apps/jaspr_pad/build/ /app/apps/jaspr_pad/
COPY --from=build /app/apps/jaspr_pad/serviceAccountKey.json /app/apps/jaspr_pad/
COPY --from=build /app/apps/jaspr_pad/templates /app/apps/jaspr_pad/templates
COPY --from=build /app/apps/jaspr_pad/samples /app/apps/jaspr_pad/samples
COPY --from=build /app/packages/jaspr /app/packages/jaspr
COPY --from=build /app/packages/jaspr_riverpod /app/packages/jaspr_riverpod

WORKDIR /app/apps/jaspr_pad/templates/jaspr_basic
RUN dart pub get

WORKDIR /app/apps/jaspr_pad

# Start server.
EXPOSE 8080

ENV DART_SDK_PATH=/usr/lib/dart

CMD ["./app"]
