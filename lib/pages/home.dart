import 'dart:io';

import 'package:band_names_al/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metalica', votes: 6),
    // Band(id: '2', name: 'Marron', votes: 5),
    // Band(id: '3', name: 'Tokio Hotel', votes: 3),
    // Band(id: '4', name: 'Linkin Park', votes: 2),
  ];
  @override
  void initState() {
    final statusService = Provider.of<SocketService>(context, listen: false);
    statusService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final statusService = Provider.of<SocketService>(context, listen: false);
    statusService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (statusService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _showGraph()),
          Expanded(
            child: ListView.builder(
                    itemCount: bands.length,
                    itemBuilder: (context, i) => _bandTitle(bands[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTitle(Band band) {
    final statusService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          statusService.socket.emit('delete-band', {'id': band.id}),
      //  print('direction: ${band.id}');
      //emitir : delete-band
      //{'id': band.id}

      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band ',
              style: TextStyle(color: Colors.white),
            ),
          )),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => statusService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (!Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: const Text('New ban name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToLits(textController.text),
                  child: const Text('Add'))
            ]),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('New band name: '),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToLits(textController.text)),
          CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  void addBandToLits(String name) {
    print(name);
    if (name.length > 1) {
      //podemos agregar
      //emitir
      //{name: name}
      final statusService = Provider.of<SocketService>(context, listen: false);
      statusService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }
  //Mostar grafica
  Widget _showGraph() {
    
  Map<String, double> dataMap = Map(); 
  //  dataMap.putIfAbsent("Flutter", () => 5);
  bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes!.toDouble());
    });
 
    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
      Colors.green[50]!,
      Colors.green[200]!,
      Colors.red[50]!,
      Colors.red[200]!,
  ];
 
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 100,
      child:PieChart(
      dataMap: dataMap.isEmpty? {'No hay datos': 0} : dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "Bandas",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),
    ),
    );

  }
}
