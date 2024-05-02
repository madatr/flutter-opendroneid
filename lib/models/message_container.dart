import 'package:dart_opendroneid/dart_opendroneid.dart';

import '../extensions/compare_extension.dart';
import '../pigeon.dart' as pigeon;
import 'constants.dart';

/// The [MessageContainer] groups together messages of different types
/// from one device. It contains one instance of each message. The container is
/// then sent using stream to client of the library.
///

extension MessageSourceExtension on pigeon.MessageSource {
  String toJsonString() {
    switch (this) {
      case pigeon.MessageSource.BluetoothLegacy:
        return 'BluetoothLegacy';
      case pigeon.MessageSource.BluetoothLongRange:
        return 'BluetoothLongRange';
      case pigeon.MessageSource.WifiNan:
        return 'WifiNan';
      case pigeon.MessageSource.WifiBeacon:
        return 'WifiBeacon';
      case pigeon.MessageSource.Unknown:
        return 'Unknown';
    }
  }
}

class MessageContainer {
  final String macAddress;
  final DateTime lastUpdate;
  final DateTime rxTime;
  DateTime? txTime;
  final DateTime? postProcessTime;

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
    required this.rxTime,
    this.txTime,
    this.postProcessTime,
    this.lastMessageRssi,
    this.basicIdMessage,
    this.locationMessage,
    this.operatorIdMessage,
    this.selfIdMessage,
    this.authenticationMessage,
    this.systemDataMessage,
  });

  @override
  String toString() =>
      "{Mac: $macAddress \n ${basicIdMessage != null ? basicIdMessage.toString() : "BasicIDMessage: NULL"} \n ${locationMessage != null ? locationMessage.toString() : "LocationMessage: NULL"} \n ${operatorIdMessage != null ? operatorIdMessage.toString() : "OperatorIdMessage: NULL"} \n ${selfIdMessage != null ? selfIdMessage.toString() : "SelfIdMessage: NULL"} \n ${authenticationMessage != null ? authenticationMessage.toString() : "AuthenticationMessage: NULL"} \n ${systemDataMessage != null ? systemDataMessage.toString() : "SystemDataMessage: NULL"} \n }";

  Map<String, dynamic> toJson() {
    return {
      'macAddress': macAddress.toString(),
      'lastUpdate': lastUpdate.toIso8601String(),
      'source': source.toJsonString(),
      'lastMessageRssi': lastMessageRssi.toString(),
      'basicIdMessage':
          basicIdMessage != null ? basicIdMessage?.toJson() : "NULL",
      'locationMessage':
          locationMessage != null ? locationMessage?.toJson() : "NULL",
      'operatorIdMessage':
          operatorIdMessage != null ? operatorIdMessage?.toJson() : "NULL",
      'selfIdMessage': selfIdMessage != null ? selfIdMessage?.toJson() : "NULL",
      'authenticationMessage': authenticationMessage != null
          ? authenticationMessage?.toJson()
          : "NULL",
      'systemDataMessage':
          systemDataMessage != null ? systemDataMessage?.toJson() : "NULL",
      'postProcessTime':
          postProcessTime != null ? postProcessTime?.toIso8601String() : "NULL",
    };
  }

  MessageContainer copyWith({
    String? macAddress,
    int? lastMessageRssi,
    DateTime? lastUpdate,
    DateTime? postProcessTime,
    pigeon.MessageSource? source,
    BasicIDMessage? basicIdMessage,
    LocationMessage? locationMessage,
    OperatorIDMessage? operatorIdMessage,
    SelfIDMessage? selfIdMessage,
    AuthMessage? authenticationMessage,
    SystemMessage? systemDataMessage,
    required DateTime rxTime,
  }) =>
      MessageContainer(
        macAddress: macAddress ?? this.macAddress,
        rxTime: rxTime,
        txTime: txTime ?? txTime,
        lastMessageRssi: lastMessageRssi ?? this.lastMessageRssi,
        lastUpdate: lastUpdate ?? DateTime.now(),
        postProcessTime: postProcessTime,
        source: source ?? this.source,
        basicIdMessage: basicIdMessage ?? this.basicIdMessage,
        locationMessage: locationMessage ?? this.locationMessage,
        operatorIdMessage: operatorIdMessage ?? this.operatorIdMessage,
        selfIdMessage: selfIdMessage ?? this.selfIdMessage,
        authenticationMessage:
            authenticationMessage ?? this.authenticationMessage,
        systemDataMessage: systemDataMessage ?? this.systemDataMessage,
      );

  /// Returns new MessageContainer updated with message.
  /// Null is returned if update is refused, because it contains duplicate or
  /// corrupted data.
  MessageContainer? update({
    required ODIDMessage message,
    required int receivedTimestamp,
    required pigeon.MessageSource source,
    int? rssi,
    DateTime? postProcessTime,
    required DateTime rxTime,
  }) {
    if (message.runtimeType == MessagePack) {
      final messages = (message as MessagePack).messages;
      var result = this;
      for (var packMessage in messages) {
        final update = result.update(
            rxTime: rxTime,
            message: packMessage,
            receivedTimestamp: receivedTimestamp,
            source: source,
            postProcessTime: postProcessTime,
            rssi: rssi);
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
              rxTime: rxTime,
              locationMessage: message as LocationMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      BasicIDMessage => basicIdMessage != null &&
              basicIdMessage!.containsEqualData(message as BasicIDMessage)
          ? null
          : copyWith(
              rxTime: rxTime,
              basicIdMessage: message as BasicIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      SelfIDMessage => selfIdMessage != null &&
              selfIdMessage!.containsEqualData(message as SelfIDMessage)
          ? null
          : copyWith(
              rxTime: rxTime,
              selfIdMessage: message as SelfIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      OperatorIDMessage => operatorIdMessage != null &&
              operatorIdMessage!.containsEqualData(message as OperatorIDMessage)
          ? null
          : copyWith(
              rxTime: rxTime,
              operatorIdMessage: message as OperatorIDMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      AuthMessage => authenticationMessage != null &&
              authenticationMessage!.containsEqualData(message as AuthMessage)
          ? null
          : copyWith(
              rxTime: rxTime,
              authenticationMessage: message as AuthMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      SystemMessage => systemDataMessage != null &&
              systemDataMessage!.containsEqualData(message as SystemMessage)
          ? null
          : copyWith(
              rxTime: rxTime,
              systemDataMessage: message as SystemMessage,
              lastMessageRssi: rssi,
              lastUpdate:
                  DateTime.fromMillisecondsSinceEpoch(receivedTimestamp),
              source: source,
              postProcessTime: postProcessTime,
            ),
      _ => null
    };
  }

  pigeon.MessageSource get packSource => source;

  bool get operatorIDSet =>
      operatorIdMessage != null &&
      operatorIdMessage!.operatorID != OPERATOR_ID_NOT_SET;

  bool get operatorIDValid {
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    return operatorIdMessage != null &&
        operatorIdMessage!.operatorID.length == 16 &&
        validCharacters.hasMatch(operatorIdMessage!.operatorID);
  }

  bool get systemDataValid =>
      systemDataMessage != null &&
      systemDataMessage?.operatorLocation != null &&
      systemDataMessage!.operatorLocation!.latitude != INV_LAT &&
      systemDataMessage?.operatorLocation!.longitude != INV_LON &&
      systemDataMessage!.operatorLocation!.latitude <= MAX_LAT &&
      systemDataMessage!.operatorLocation!.latitude >= MIN_LAT &&
      systemDataMessage!.operatorLocation!.longitude <= MAX_LON &&
      systemDataMessage!.operatorLocation!.longitude >= MIN_LON;

  bool get locationValid =>
      locationMessage != null &&
      locationMessage?.location != null &&
      locationMessage!.location!.latitude != INV_LAT &&
      locationMessage!.location!.longitude != INV_LON &&
      locationMessage!.location!.latitude <= MAX_LAT &&
      locationMessage!.location!.longitude <= MAX_LON &&
      locationMessage!.location!.latitude >= MIN_LAT &&
      locationMessage!.location!.longitude >= MIN_LON;
}
