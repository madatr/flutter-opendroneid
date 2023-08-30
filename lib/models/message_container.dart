import 'dart:ui';

import 'package:flutter_opendroneid/models/constants.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:dart_opendroneid/src/types.dart';
import 'package:flutter_opendroneid/utils/compare_extension.dart';

class MessageContainer {
  final String macAddress;
  final DateTime lastUpdate;
  final pigeon.MessageSource source;
  final int? lastMessageRssi;

  final BasicIDMessage? basicIdMessage;
  final LocationMessage? locationMessage;
  final OperatorIDMessage? operatorIdMessage;
  final SelfIDMessage? selfIdMessage;
  final AuthMessage? authenticationMessage;
  final SystemMessage? systemDataMessage;

  MessageContainer({
    required this.macAddress,
    required this.lastUpdate,
    required this.source,
    this.lastMessageRssi,
    this.basicIdMessage,
    this.locationMessage,
    this.operatorIdMessage,
    this.selfIdMessage,
    this.authenticationMessage,
    this.systemDataMessage,
  });

  static const colorMax = 120;
  static const colorOffset = 90;

  MessageContainer copyWith({
    String? macAddress,
    int? lastMessageRssi,
    DateTime? lastUpdate,
    pigeon.MessageSource? source,
    BasicIDMessage? basicIdMessage,
    LocationMessage? locationMessage,
    OperatorIDMessage? operatorIdMessage,
    SelfIDMessage? selfIdMessage,
    AuthMessage? authenticationMessage,
    SystemMessage? systemDataMessage,
  }) =>
      MessageContainer(
        macAddress: macAddress ?? this.macAddress,
        lastMessageRssi: lastMessageRssi ?? this.lastMessageRssi,
        lastUpdate: lastUpdate ?? DateTime.now(),
        source: source ?? this.source,
        basicIdMessage: basicIdMessage ?? this.basicIdMessage,
        locationMessage: locationMessage ?? this.locationMessage,
        operatorIdMessage: operatorIdMessage ?? this.operatorIdMessage,
        selfIdMessage: selfIdMessage ?? this.selfIdMessage,
        authenticationMessage:
            authenticationMessage ?? this.authenticationMessage,
        systemDataMessage: systemDataMessage ?? this.systemDataMessage,
      );

  MessageContainer? update({
    required ODIDMessage message,
    required int receivedTimestamp,
    required pigeon.MessageSource source,
    int? rssi,
  }) {
    if (message.runtimeType == MessagePack) {
      final messages = (message as MessagePack).messages;
      var result = this;
      for (var packMessage in messages) {
        final update = result.update(
          message: packMessage,
          receivedTimestamp: receivedTimestamp,
          source: source,
        );
        if (update != null) result = update;
      }
      return result;
    }
    // update pack only if new data differ from saved ones
    return switch (message.runtimeType) {
      LocationMessage => locationMessage != null &&
              locationMessage!.containsEqualData(message as LocationMessage)
          ? null
          : copyWith(
              locationMessage: message as LocationMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      BasicIDMessage => basicIdMessage != null &&
              basicIdMessage!.containsEqualData(message as BasicIDMessage)
          ? null
          : copyWith(
              basicIdMessage: message as BasicIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      SelfIDMessage => selfIdMessage != null &&
              selfIdMessage!.containsEqualData(message as SelfIDMessage)
          ? null
          : copyWith(
              selfIdMessage: message as SelfIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      OperatorIDMessage => operatorIdMessage != null &&
              operatorIdMessage!.containsEqualData(message as OperatorIDMessage)
          ? null
          : copyWith(
              operatorIdMessage: message as OperatorIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      AuthMessage => authenticationMessage != null &&
              authenticationMessage!.containsEqualData(message as AuthMessage)
          ? null
          : copyWith(
              authenticationMessage: message as AuthMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      SystemMessage => systemDataMessage != null &&
              systemDataMessage!.containsEqualData(message as SystemMessage)
          ? null
          : copyWith(
              systemDataMessage: message as SystemMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
            ),
      _ => null
    };
  }

  pigeon.MessageSource getPackSource() => source;

  /// Calculates a color from mac address, that uniquely identifies the device
  Color getPackColor() {
    final len = macAddress.length;
    return Color.fromARGB(
      locationMessage?.status != OperationalStatus.airborne ? 80 : 255,
      colorOffset +
          32 +
          macAddress
                  .substring(0, len ~/ 2)
                  .codeUnits
                  .reduce((sum, e) => sum + e) %
              (colorMax - 32),
      colorOffset +
          macAddress.codeUnits.reduce((sum, e) => (sum * e) % colorMax),
      colorOffset +
          macAddress
              .substring(len ~/ 2)
              .codeUnits
              .fold(255, (sum, e) => sum - e % colorMax),
    );
  }

  bool operatorIDSet() {
    return operatorIdMessage != null &&
        operatorIdMessage!.operatorID != OPERATOR_ID_NOT_SET;
  }

  bool operatorIDValid() {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return operatorIdMessage != null &&
        operatorIdMessage!.operatorID.length == 16 &&
        validCharacters.hasMatch(operatorIdMessage!.operatorID);
  }

  bool systemDataValid() {
    return systemDataMessage != null &&
        systemDataMessage?.operatorLocation != null &&
        systemDataMessage!.operatorLocation!.latitude != INV_LAT &&
        systemDataMessage?.operatorLocation!.longitude != INV_LON &&
        systemDataMessage!.operatorLocation!.latitude <= MAX_LAT &&
        systemDataMessage!.operatorLocation!.latitude >= MIN_LAT &&
        systemDataMessage!.operatorLocation!.longitude <= MAX_LON &&
        systemDataMessage!.operatorLocation!.longitude >= MIN_LON;
  }

  bool locationValid() {
    return locationMessage != null &&
        locationMessage?.location != null &&
        locationMessage!.location!.latitude != INV_LAT &&
        locationMessage!.location!.longitude != INV_LON &&
        locationMessage!.location!.latitude <= MAX_LAT &&
        locationMessage!.location!.longitude <= MAX_LON &&
        locationMessage!.location!.latitude >= MIN_LAT &&
        locationMessage!.location!.longitude >= MIN_LON;
  }
}
