import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/domain/repository/auth_repository.dart';

class NotificationRealtimeService {
  final AuthRepository _authRepository;
  HubConnection? _connection;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  NotificationRealtimeService(this._authRepository);

  Stream<Map<String, dynamic>> get events => _controller.stream;

  Future<void> connect() async {
    final token = await _authRepository.getAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    if (_connection != null) {
      if (_connection!.state == HubConnectionState.Connected ||
          _connection!.state == HubConnectionState.Connecting) {
        return;
      }
    }

    final url = '${ApiUrls.baseUrl}/hubs/notifications';

    _connection = HubConnectionBuilder()
        .withUrl(
          url,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => (await _authRepository.getAccessToken()) ?? '',
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('notification:created', (arguments) {
      if (arguments == null || arguments.isEmpty) {
        return;
      }

      final payload = arguments.first;
      if (payload is Map<String, dynamic>) {
        _controller.add(payload);
      } else if (payload is Map) {
        _controller.add(payload.map((key, value) => MapEntry(key.toString(), value)));
      }
    });

    await _connection!.start();
  }

  Future<void> disconnect() async {
    if (_connection == null) {
      return;
    }

    try {
      await _connection!.stop();
    } finally {
      _connection = null;
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}
