# We need a docker image that contains flutter for our flutter plugin support.
FROM instrumentisto/flutter as build

RUN dart pub global activate jaspr_cli

WORKDIR /app
COPY . .

# Resolve app dependencies.
RUN rm -f pubspec_overrides.yaml
RUN dart pub get

# Build project
RUN dart pub global run jaspr_cli:jaspr build

FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/build/jaspr/ /app/
COPY --from=build /app/service-account.json /app/

WORKDIR /app

# Start server.
EXPOSE 8080
CMD ["./app"]
