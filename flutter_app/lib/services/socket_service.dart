import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SocketService {
  static IO.Socket? _socket;

  // ─── Existing stream controllers ───────────────────────────────────────────
  static final _canteenStatusCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _menuUpdateCtrl    = StreamController<Map<String, dynamic>>.broadcast();
  static final _reviewCtrl        = StreamController<Map<String, dynamic>>.broadcast();
  static final _orderCtrl         = StreamController<Map<String, dynamic>>.broadcast();
  static final _broadcastCtrl     = StreamController<Map<String, dynamic>>.broadcast();

  // ─── New pre-order stream controllers ─────────────────────────────────────
  static final _preOrderSoldOutCtrl  = StreamController<Map<String, dynamic>>.broadcast();
  static final _preOrderCapacityCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _nowServingCtrl       = StreamController<Map<String, dynamic>>.broadcast();
  static final _tokenGeneratedCtrl   = StreamController<Map<String, dynamic>>.broadcast();

  // ─── Existing streams ──────────────────────────────────────────────────────
  static Stream<Map<String, dynamic>> get canteenStatusStream => _canteenStatusCtrl.stream;
  static Stream<Map<String, dynamic>> get menuUpdateStream    => _menuUpdateCtrl.stream;
  static Stream<Map<String, dynamic>> get reviewStream        => _reviewCtrl.stream;
  static Stream<Map<String, dynamic>> get orderStream         => _orderCtrl.stream;
  static Stream<Map<String, dynamic>> get broadcastStream     => _broadcastCtrl.stream;

  // ─── New pre-order streams ─────────────────────────────────────────────────
  static Stream<Map<String, dynamic>> get preOrderSoldOutStream  => _preOrderSoldOutCtrl.stream;
  static Stream<Map<String, dynamic>> get preOrderCapacityStream => _preOrderCapacityCtrl.stream;
  static Stream<Map<String, dynamic>> get nowServingStream       => _nowServingCtrl.stream;
  static Stream<Map<String, dynamic>> get tokenGeneratedStream   => _tokenGeneratedCtrl.stream;

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    _socket = IO.io(ApiConfig.socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setAuth({'token': token})
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket Connected');
    });

    // ─── Existing event handlers ───────────────────────────────────────────
    _socket!.on('canteen:status',    (data) => _canteenStatusCtrl.add(_toMap(data)));
    _socket!.on('menu:itemUpdate',   (data) => _menuUpdateCtrl.add(_toMap(data)));
    _socket!.on('menu:itemCreated',  (data) => _menuUpdateCtrl.add(_toMap(data)));
    _socket!.on('menu:itemDeleted',  (data) => _menuUpdateCtrl.add(_toMap(data)));
    _socket!.on('review:new',        (data) => _reviewCtrl.add(_toMap(data)));
    _socket!.on('order:statusUpdate',(data) => _orderCtrl.add(_toMap(data)));
    _socket!.on('admin:broadcast',   (data) => _broadcastCtrl.add(_toMap(data)));

    // ─── New pre-order event handlers ─────────────────────────────────────
    _socket!.on('pre_order:soldOut', (data) {
      _preOrderSoldOutCtrl.add(_toMap(data));
    });

    _socket!.on('pre_order:capacityUpdate', (data) {
      _preOrderCapacityCtrl.add(_toMap(data));
    });

    _socket!.on('canteen:nowServing', (data) {
      _nowServingCtrl.add(_toMap(data));
    });

    _socket!.on('order:tokenGenerated', (data) {
      _tokenGeneratedCtrl.add(_toMap(data));
    });

    _socket!.onDisconnect((_) => print('Socket Disconnected'));
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Safely cast dynamic socket data to Map<String, dynamic>.
  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
