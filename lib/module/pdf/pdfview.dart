import 'package:flutter/material.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  const PDFViewerPage({super.key, required this.pdfUrl});
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  _loadPDF() async {

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(),
    );
  }
}
