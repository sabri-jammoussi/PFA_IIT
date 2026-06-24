import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:dentiflow/config/app_config.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';

class SignalRNotificationEvent {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isSeen;

  SignalRNotificationEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isSeen,
  });

  factory SignalRNotificationEvent.fromJson(Map<String, dynamic> json) =>
      SignalRNotificationEvent(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        // Server payload uses "description"; tolerate a few aliases.
        description: (json['description'] ?? json['note'] ?? json['message'])
                ?.toString() ??
            '',
        type: json['type']?.toString() ?? '',
        isSeen: json['isSeen'] == true,
      );
}

class SignalRService {
  SignalRService._internal();
  static final SignalRService instance = SignalRService._internal();

  HubConnection? _hubConnection;
  final StreamController<SignalRNotificationEvent> notificationEventsStream =
      StreamController<SignalRNotificationEvent>.broadcast();

  Future<void> init() async {
    try {
      final String? token = await SecureStorage.readToken();
      final String hubUrl = AppConfig.getSignalRHubUrl();

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => token ?? '',
              ))
          .withAutomaticReconnect()
          .build();

      // The server pushes via INotificationHubClient.ReceiveMessage.
      void handle(List<Object?>? args) {
        if (args != null && args.isNotEmpty && args[0] is Map) {
          final event = SignalRNotificationEvent.fromJson(
              Map<String, dynamic>.from(args[0] as Map));
          notificationEventsStream.add(event);
        }
      }

      _hubConnection!.on('ReceiveMessage', handle);
      // Keep the legacy name too, in case other emitters use it.
      _hubConnection!.on('ReceiveNotification', handle);

      await _hubConnection!.start();
    } catch (e) {
      debugPrint('[SignalR] init failed: $e');
    }
  }

  Future<void> disconnectAll() async {
    try {
      await _hubConnection?.stop();
    } catch (_) {}
  }
}
