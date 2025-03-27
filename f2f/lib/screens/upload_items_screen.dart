import 'package:flutter/material.dart';

class UploadItemsScreen extends StatefulWidget {
  const UploadItemsScreen({Key? key}) : super(key: key);

  @override
  State<UploadItemsScreen> createState() => _UploadItemsScreenState();
}

class _UploadItemsScreenState extends State<UploadItemsScreen> {
  String? selectedItem;

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.apple_sharp,
                  color: Colors.red,
                  size: 28,
                ),
                title: const Text('Fruits'),
                onTap: () {
                  setState(() {
                    selectedItem = 'Fruits';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 28,
                ),
                title: const Text('Vegetables'),
                onTap: () {
                  setState(() {
                    selectedItem = 'Vegetables';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.grass,
                  color: Colors.lightGreen,
                  size: 28,
                ),
                title: const Text('Leafy Vegetables'),
                onTap: () {
                  setState(() {
                    selectedItem = 'Leafy Vegetables';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Items'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _showOptionsBottomSheet,
              icon: const Icon(Icons.add,color: Colors.white),
              label: const Text('Add Items'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (selectedItem != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Selected: $selectedItem',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}