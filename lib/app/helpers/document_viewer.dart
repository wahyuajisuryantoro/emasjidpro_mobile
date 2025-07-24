import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewer extends StatefulWidget {
  final String url;
  final String fileName;

  const DocumentViewer({Key? key, required this.url, required this.fileName}) : super(key: key);

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  bool isLoading = true;
  String? localPath;
  String? error;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName}');
      
      if (await file.exists()) {
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(widget.url));
      await file.writeAsBytes(response.bodyBytes);
      
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('Error loading file', style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                _downloadFile();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final extension = widget.fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return SfPdfViewer.file(File(localPath!));
      case 'jpg':
      case 'jpeg':
      case 'png':
        return PhotoView(
          imageProvider: FileImage(File(localPath!)),
          backgroundDecoration: BoxDecoration(color: Colors.black),
        );
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 64, color: Colors.white),
              SizedBox(height: 16),
              Text(
                widget.fileName,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'File downloaded to device',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        );
    }
  }
}