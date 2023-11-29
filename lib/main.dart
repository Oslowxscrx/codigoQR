import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR/Barras Scanner',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QRScannerScreen(),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String qrResult = 'Escanear código QR';
  bool isURL = false;

  Future<void> scanQR() async {
    try {
      String? result = await scanner.scan();
      setState(() {
        qrResult = result!;
        isURL = _checkIfURL(result);
      });

      if (isURL) {
        Clipboard.setData(ClipboardData(text: result!));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enlace copiado al portapapeles'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        qrResult = 'Error al escanear: $e';
      });
    }
  }

  Future<void> scanFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        String? result = await scanner.scanPath(pickedFile.path);
        setState(() {
          qrResult = result!;
          isURL = _checkIfURL(result);
        });

        if (isURL) {
          Clipboard.setData(ClipboardData(text: result));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Enlace copiado al portapapeles'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        qrResult = 'Error al escanear desde la galería: $e';
      });
    }
  }

  bool _checkIfURL(String text) {
    return Uri.tryParse(text)?.hasScheme ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escaner QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (isURL) {
                  Clipboard.setData(ClipboardData(text: qrResult));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Enlace copiado al portapapeles'),
                    ),
                  );
                }
              },
              child: Text(
                qrResult,
                style: TextStyle(
                  fontSize: 20.0,
                  color: isURL ? Colors.blue : Colors.black,
                  decoration: isURL ? TextDecoration.underline : TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => scanQR(),
            tooltip: 'Escanear código QR',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () => scanFromGallery(),
            tooltip: 'Escanear desde galería',
            child: Icon(Icons.image),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: isURL
          ? BottomAppBar(
              child: Container(
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrResult));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Enlace copiado al portapapeles'),
                          ),
                        );
                      },
                      child: Text('Copiar enlace'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
