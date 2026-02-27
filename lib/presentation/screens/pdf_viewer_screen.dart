import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;

  const PDFViewerScreen({
    Key? key,
    required this.pdfPath,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  static const platform = MethodChannel('com.example.smart_nutrition/pdf');

  @override
  void initState() {
    super.initState();
    _openPDF();
  }

  Future<void> _openPDF() async {
    try {
      final file = File(widget.pdfPath);
      
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF file not found: ${widget.pdfPath}'),
              backgroundColor: Colors.red,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
        return;
      }

      await platform.invokeMethod('openPDF', {
        'filePath': widget.pdfPath,
      });

      // Close the screen after opening PDF
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Report'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Opening PDF...'),
          ],
        ),
      ),
    );
  }
}
