import 'package:jaspr/server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'main.server.options.dart';
import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/routes/root.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void main(List<String> args) async {
  if (_runningPod case final pod?) {
    await pod.shutdown(exitProcess: false);
  }

  // Initialize Serverpod and connect it with your generated code.
  final pod = _runningPod = Serverpod(args, Protocol(), Endpoints());

  // Set up authentication services
  // The `pod.getPassword()` will get the value from `config/passwords.yaml`.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      JwtConfig(
        // Pepper used to hash the refresh token secret.
        refreshTokenHashPepper: pod.getPassword('jwtRefreshTokenHashPepper')!,
        // Algorithm used to sign the tokens (`hmacSha512` or `ecdsaSha512`).
        algorithm: JwtAlgorithm.hmacSha512(
          // Private key to sign the tokens. Must be a valid HMAC SHA-512 key.
          SecretKey(pod.getPassword('jwtHmacSha512PrivateKey')!),
        ),
      ),
    ],
    identityProviderBuilders: [
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJsonString(
          pod.getPassword('googleClientSecret')!,
        ),
      ),
    ],
  );

  Jaspr.initializeApp(options: defaultServerOptions, useIsolates: false);

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  pod.webServer.addRoute(auth.RouteGoogleSignIn(), '/googlesignin');
  pod.webServer.addRoute(RootRoute());

  // Start the server.
  await pod.start();
}

Serverpod? _runningPod;
