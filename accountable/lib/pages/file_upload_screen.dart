import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../app_state.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  bool isAutomaticUpload = false;
  bool isProcessing = false;
  String? selectedImagePath;
  Map<String, dynamic>? extractedData;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show a dialog to choose between camera and gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (source == null) return;
    
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
        extractedData = null;
        isProcessing = true;
      });
      
      // Process the image
      await _processEslip(image.path);
    }
  }
  
  Future<void> _processEslip(String imagePath) async {
    // Create ReceiptFile instance
    ReceiptFile receiptFile = ReceiptFile(
      name: imagePath.split('/').last,
      path: imagePath,
    );
    
    // Process the e-slip with OCR
    Map<String, dynamic> result = await receiptFile.OCRBS();
    
    setState(() {
      extractedData = result;
      isProcessing = false;
    });
    
    // Add the receipt to the app state
    if (result['recipient'] != null || result['amount'] != null) {
      Provider.of<AppState>(context, listen: false).receipts.add(receiptFile);
      
      // If automatic upload is enabled, create transaction
      if (isAutomaticUpload && result['amount'] != null) {
        String transName = result['recipient'] ?? 'Unknown Recipient';
        double amount = result['amount'] ?? 0.0;
        
        Trans transaction = Trans(
          transName: transName,
          transactionDate: DateTime.now(),
          amount: amount,
        );
        
        Provider.of<AppState>(context, listen: false).transList.addTransaction(transaction);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added: $transName - ฿${amount.toStringAsFixed(2)}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: const Text('Upload E-Slip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Automatic Upload',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: isAutomaticUpload,
                    onChanged: (value) {
                      setState(() {
                        isAutomaticUpload = value;
                      });
                    },
                    activeColor: Colors.white,
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Preview of selected image
            if (selectedImagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(selectedImagePath!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            
            if (selectedImagePath == null)
              Column(
                children: [
                  const Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select an e-slip image to process',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              
            const SizedBox(height: 20),
            
            // Loading indicator during processing
            if (isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Processing e-slip with OCR...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              
            // Display extracted data
            if (extractedData != null && !isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extracted Data:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recipient: ${extractedData!['recipient'] ?? 'Not detected'}',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${extractedData!['amount'] != null ? '฿${extractedData!['amount'].toStringAsFixed(2)}' : 'Not detected'}',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (extractedData!.containsKey('error'))
                      Text(
                        'Error: ${extractedData!['error']}',
                        style: TextStyle(color: Colors.red.shade300),
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Button to select e-slip image
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SELECT E-SLIP IMAGE',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addTransaction');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add a transaction manually',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
