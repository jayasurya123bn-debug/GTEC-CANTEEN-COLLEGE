import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SocketService {
  static IO.Socket? _socket;
  
  // Stream controllers for different events
  static final _canteenStatusCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _menuUpdateCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _reviewCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _orderCtrl = StreamController<Map<String, dynamic>>.broadcast();
  static final _broadcastCtrl = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get canteenStatusStream => _canteenStatusCtrl.stream;
  static Stream<Map<String, dynamic>> get menuUpdateStream => _menuUpdateCtrl.stream;
  static Stream<Map<String, dynamic>> get reviewStream => _reviewCtrl.stream;
  static Stream<Map<String, dynamic>> get orderStream => _orderCtrl.stream;
  static Stream<Map<String, dynamic>> get broadcastStream => _broadcastCtrl.stream;

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

    _socket!.on('canteen:status', (data) => _canteenStatusCtrl.add(data));
    _socket!.on('menu:itemUpdate', (data) => _menuUpdateCtrl.add(data));
    _socket!.on('menu:itemCreated', (data) => _menuUpdateCtrl.add(data)); // Can reuse controller or separate
    _socket!.on('menu:itemDeleted', (data) => _menuUpdateCtrl.add(data));
    _socket!.on('review:new', (data) => _reviewCtrl.add(data));
    _socket!.on('order:statusUpdate', (data) => _orderCtrl.add(data));
    _socket!.on('admin:broadcast', (data) => _broadcastCtrl.add(data));

    _socket!.onDisconnect((_) => print('Socket Disconnected'));
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
