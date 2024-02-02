import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
 
enum ServerStatus { 
  Online, 
  Offline, 
  Connecting 
}
 
class SocketService with ChangeNotifier {
  
    ServerStatus _serverStatus = ServerStatus.Connecting;
    late IO.Socket _socket;
 
    ServerStatus get serverStatus => _serverStatus;
    IO.Socket get socket => _socket;

    Function get emit => _socket.emit;
 
    SocketService() {
      _initConfig();
    
  }
 
  void _initConfig() {
 
    //dart client
    _socket = IO.io('http://192.168.18.60:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
 
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      print('connect');
      notifyListeners();
    });
 
    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      print('disconnect');
      notifyListeners();
    });
    
    // socket.on('nuevo-mensaje', ( payload ) {
    //   // print( 'nuevo-mensaje: ${payload}' );
    //   print( 'nuevo-mensaje:' );
    //   print( 'nombre:' + payload['nombre'] );
    //   print( 'mensaje:' + payload['mensaje'] );
 
    // });
 
  }
}