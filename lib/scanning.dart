import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;

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
      print(code);
    try {
      // Fetch the document from Firebase
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('responses').doc(code).get();
      
      if (docSnapshot.exists) {
        // Cross-verify the scanned document ID with the existing IDs
        var data = docSnapshot.data() as Map<String, dynamic>;

        print(data);
        if (docSnapshot.id == code ) {
          // Mark the document as scanned
          await FirebaseFirestore.instance.collection('responses').doc(code).update({'is_scanned': true});

          // Verification successful
          _showMessage('Verification complete');
        } else {
          // Already scanned or verification failed
          _showMessage('Verification failed or already scanned');
        }
      } else {
        // Document does not exist
        _showMessage('Invalid QR code');
      }
    } catch (e) {
      // Handle any errors
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
            onPressed: () => Navigator.of(context).pop(),
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
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (hasScanned)
                  ? const Text('QR Code has been scanned.')
                  : const Text('Scan a QR code'),
            ),
          ),
        ],
      ),
    );
  }
}
