import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(ProductFinderApp());

class ProductFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductFinderScreen(),
    );
  }
}

class ProductFinderScreen extends StatefulWidget {
  @override
  _ProductFinderScreenState createState() => _ProductFinderScreenState();
}

class _ProductFinderScreenState extends State<ProductFinderScreen> {
  File? _image;
  String _result = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // or .camera

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = 'Searching...';
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var uri = Uri.parse('http://YOUR-SERVER-IP:5000/search');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var jsonResp = json.decode(respStr);
      setState(() {
        _result = jsonResp['result'];
      });
    } else {
      setState(() {
        _result = 'Error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visual Product Search')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null ? Image.file(_image!) : Text("No image selected"),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: Text("Upload Product Image")),
            SizedBox(height: 20),
            Text(_result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
