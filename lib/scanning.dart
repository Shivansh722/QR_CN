import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('QR Scanner',
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
          ),
          // Overlay for QR scanner to make it look stylish
          _buildOverlay(),
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

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Top left black overlay
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            height: 100,
            width: 100,
          ),
        ),
        // Top right black overlay
        Align(
          alignment: Alignment.topRight,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            height: 100,
            width: 100,
          ),
        ),
        // Bottom left black overlay
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            height: 100,
            width: 100,
          ),
        ),
        // Bottom right black overlay
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            height: 100,
            width: 100,
          ),
        ),
        // Center transparent cutout for scanning
        Center(
  child: Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
      // Rounded corners
      borderRadius: BorderRadius.circular(20),
      // Thicker and bold borders for the corners
      border: Border.all(
        color: Colors.white,
        width: 6, // Make this thicker than the other borders
      ),
    ),
    // Adding inner container for the corners to be even thicker
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: 8),
            bottom: BorderSide(color: Colors.white, width: 8),
            left: BorderSide(color: Colors.white, width: 8),
            right: BorderSide(color: Colors.white, width: 8),
          ),
        ),
      ),
    ),
  ),
),

      ],
    );
  }
}
