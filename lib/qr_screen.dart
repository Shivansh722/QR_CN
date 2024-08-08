import 'package:flutter/material.dart';
import 'package:qr_scanner/scanning.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_scanner/registeredPeopleScreen.dart';
import 'package:qr_scanner/verifiedPeopleScreen.dart'; // Make sure to import the QR scanner screen

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegesteredPpl()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'Registered People',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Verifiedpeoplescreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.green,
                    child: const Center(
                      child: Text(
                        'Verified People',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Scan a QR code',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
