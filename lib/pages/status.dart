import 'package:band_names_al/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Server Status: ${socketService.serverStatus}'),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          socketService.socket.emit('emitir-mensaje', {
            'nombre': 'Flutter',
            'mensaje': 'Hola desde Flutter'
          });
        },
        child: const Icon(Icons.message),) 
    );
  }
}
