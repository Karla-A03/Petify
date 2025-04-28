import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:typed_data';

class BluetoothVisitsPage extends StatefulWidget {
  const BluetoothVisitsPage({Key? key}) : super(key: key);

  @override
  State<BluetoothVisitsPage> createState() => _BluetoothVisitsPageState();
}

class _BluetoothVisitsPageState extends State<BluetoothVisitsPage> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  String? connectedEndpoint;
  bool isConnected = false;
  bool simulateVisit = false;
  bool isWaitingForConnection = false;
  String waitingMessage = "";

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() {
    Nearby().askLocationPermission();
    Nearby().askExternalStoragePermission();
    Nearby().askBluetoothPermission();
  }

  void startAdvertising() async {
    try {
      setState(() {
        isWaitingForConnection = true;
        waitingMessage = "Esperando que otro usuario se conecte...";
      });

      await Nearby().startAdvertising(
        "PetifyUser",
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            setState(() {
              connectedEndpoint = id;
              isConnected = true;
              isWaitingForConnection = false;
            });
          }
        },
        onDisconnected: (id) {
          setState(() {
            connectedEndpoint = null;
            isConnected = false;
            isWaitingForConnection = false;
          });
        },
      );

      // No importa si falla Nearby, mantenemos esperando
    } catch (e) {
      // Tampoco cancelamos isWaitingForConnection si falla
    }
  }

  void startDiscovery() async {
    try {
      setState(() {
        isWaitingForConnection = true;
        waitingMessage = "Buscando otros usuarios cerca...";
      });

      await Nearby().startDiscovery(
        "PetifyUser",
        strategy,
        onEndpointFound: (id, name, serviceId) {
          Nearby().requestConnection(
            "PetifyUser",
            id,
            onConnectionInitiated: onConnectionInit,
            onConnectionResult: (id, status) {
              if (status == Status.CONNECTED) {
                setState(() {
                  connectedEndpoint = id;
                  isConnected = true;
                  isWaitingForConnection = false;
                });
              }
            },
            onDisconnected: (id) {
              setState(() {
                connectedEndpoint = null;
                isConnected = false;
                isWaitingForConnection = false;
              });
            },
          );
        },
        onEndpointLost: (id) {},
      );

      // No importa si falla Nearby, mantenemos esperando
    } catch (e) {
      // Tampoco cancelamos isWaitingForConnection si falla
    }
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) {
        if (payload.bytes != null) {
          String message = String.fromCharCodes(payload.bytes!);
          if (message == "VISIT") {
            showVisitReceived(simulated: false);
          }
        }
      },
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
    );
  }

  void sendVisit() {
    if (isConnected && connectedEndpoint != null) {
      Nearby().sendBytesPayload(
        connectedEndpoint!,
        Uint8List.fromList("VISIT".codeUnits),
      );
      showVisitSent();
    } else {
      showVisitReceived(simulated: true);
    }
  }

  void showVisitReceived({required bool simulated}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Visita recibida!'),
        content: Text(simulated
            ? "✨ Visita simulada a tu mascota ✨"
            : "✨ ¡Alguien visitó a tu mascota! ✨"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showVisitSent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Visita enviada ✨")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petify - Visitar Mascotas'),
        backgroundColor:
            const Color(0xFF0E5C61), // Color azul oscuro en el appbar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF57F5FF), // Mismo degradado que login
              Color(0xFF0E5C61),
            ],
          ),
        ),
        child: Center(
          child: isWaitingForConnection
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bluetooth_searching,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        waitingMessage,
                        key: ValueKey(waitingMessage),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E8F95),
                        side: const BorderSide(color: Color(0xFF2E8F95)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isWaitingForConnection = false;
                        });
                        Nearby().stopAdvertising();
                        Nearby().stopDiscovery();
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: startAdvertising,
                      child: const Text('Ser Anfitrión (Esperar conexión)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startDiscovery,
                      child: const Text('Ser Invitado (Buscar conexión)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: sendVisit,
                      child: const Text('Visitar Mascota'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
