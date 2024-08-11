import 'package:flutter/material.dart';
import 'package:qr_scanner/scanning.dart';
import 'package:qr_scanner/verifiedPeopleScreen.dart';
import 'package:qr_scanner/registeredPeopleScreen.dart';


class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine the padding and container height based on screen size
    final double paddingValue = screenWidth * 0.02;
    final double containerHeight = screenHeight * 0.12;
    final double imageHeight = screenHeight * 0.25;

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.black,
  title: Center(
    child: Text('QR Scanner',
      style: TextStyle(color: Colors.white),
    ),
  ),
),
      backgroundColor: Colors.black, // Set background color to black
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisteredPpl()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(paddingValue),
                child: Container(
                  height: containerHeight,
                  padding: EdgeInsets.all(paddingValue),
                  decoration: BoxDecoration(
                    color: Colors.grey[850], // Set the tile background to dark grey
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(paddingValue),
                        child: const Icon(Icons.people, color: Colors.white), // Icon color set to white
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Registered People',
                            style: TextStyle(
                              color: Colors.white, // Text color set to white
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifiedPeopleScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(paddingValue),
                child: Container(
                  height: containerHeight,
                  padding: EdgeInsets.all(paddingValue),
                  decoration: BoxDecoration(
                    color: Colors.grey[850], // Set the tile background to dark grey
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(paddingValue),
                        child: const Icon(Icons.check_circle, color: Colors.white), // Icon color set to white
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Verified People',
                            style: TextStyle(
                              color: Colors.white, // Text color set to white
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.2),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(paddingValue),
                child: Container(
                  height: imageHeight,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Image.asset(
                    'assets/qr2.gif',
                    width: screenWidth * 0.8,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
