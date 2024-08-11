import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_scanner/verifiedPeopleScreen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;
  final List<Map<String, dynamic>> verifiedPeople = [];

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (!hasScanned) {
        setState(() {
          hasScanned = true;
        });
        await _verifyQRCode(scanData.code);
      }
    });
  }

  Future<void> _verifyQRCode(String? code) async {
    if (code == null) return;
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('responses').doc(code).get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        if (docSnapshot.id == code) {
          await FirebaseFirestore.instance.collection('responses').doc(code).update({'is_scanned': true});

          setState(() {
            verifiedPeople.add(data);
          });

          _showMessage('Verification complete');
        } else {
          _showMessage('Verification failed or already scanned');
        }
      } else {
        _showMessage('Invalid QR code');
      }
    } catch (e) {
      _showMessage('Error occurred: $e');
    }
  }

  void _showMessage(String message) {
    _triggerVibration();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Result'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (verifiedPeople.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifiedPeopleScreen(),
                  ),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _triggerVibration() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Vibrate.canVibrate) {
        Vibrate.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'QR Scanner',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // QR View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 20,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.8, // Adjust the cutout size
            ),
          ),
          // Bottom message
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Center(
              child: (hasScanned)
                  ? const Text(
                      'QR Code has been scanned.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(
                      'Align QR code within the frame to scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
