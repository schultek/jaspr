/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:dart_quotes_client/src/protocol/quote.dart' as _i3;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i4;
import 'protocol.dart' as _i5;

/// {@category Endpoint}
class EndpointQuotes extends _i1.EndpointRef {
  EndpointQuotes(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'quotes';

  _i2.Future<void> toggleLikeOnQuote(
    int id,
    bool liked,
  ) =>
      caller.callServerEndpoint<void>(
        'quotes',
        'toggleLikeOnQuote',
        {
          'id': id,
          'liked': liked,
        },
      );

  _i2.Stream<_i3.Quote> subscribeToQuote(int id) =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i3.Quote>, _i3.Quote>(
        'quotes',
        'subscribeToQuote',
        {'id': id},
        {},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i4.Caller(client);
  }

  late final _i4.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i5.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection: disconnectStreamsOnLostInternetConnection,
        ) {
    quotes = EndpointQuotes(this);
    modules = Modules(this);
  }

  late final EndpointQuotes quotes;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'quotes': quotes};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {'auth': modules.auth};
}
