import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;

  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  int _currentStep = 0;

  Position? _farmLocation;
  PlatformFile? _farmerIdDoc;
  PlatformFile? _passbookDoc;
  PlatformFile? _aadharDoc;

  final List<String> _farmingTypes = [
    'Vegetables', 'Fruits'
  ];

  List<Step> get _steps => [
    Step(
      title: const Text('Personal', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildPersonalDetails(),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Farm', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildFarmDetails(),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Verification', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildVerificationDetails(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.role} Registration',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/farmer_login');
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Already a user?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            steps: _steps,
            onStepContinue: _continue,
            onStepCancel: _cancel,
            controlsBuilder: _buildControls,
            elevation: 0,
            type: StepperType.vertical,
            physics: const ClampingScrollPhysics(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload('Farmer ID Document', _farmerIdDoc, (file) => setState(() => _farmerIdDoc = file)),
            _buildDocumentUpload('Farming Passbook', _passbookDoc, (file) => setState(() => _passbookDoc = file)),
            _buildDocumentUpload('Aadhar Card (Optional)', _aadharDoc, (file) => setState(() => _aadharDoc = file)),
            const SizedBox(height: 16),
            const Text(
              'Bank Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Bank Account Number',
                prefixIcon: const Icon(Icons.account_balance, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter bank account number' : null,
              onSaved: (value) => _formData['Bank Account Number'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Account Holder Name',
                prefixIcon: const Icon(Icons.person, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter account holder name' : null,
              onSaved: (value) => _formData['Account Holder Name'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Bank Name',
                prefixIcon: const Icon(Icons.business, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter bank name' : null,
              onSaved: (value) => _formData['Bank Name'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'IFSC Code',
                prefixIcon: const Icon(Icons.code, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter IFSC code' : null,
              onSaved: (value) => _formData['IFSC Code'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          if (_currentStep != 0)
            TextButton.icon(
              onPressed: details.onStepCancel,
              icon: const Icon(Icons.arrow_back),
              label: const Text('BACK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: details.onStepContinue,
            icon: Icon(_currentStep == _steps.length - 1 ? Icons.check : Icons.arrow_forward),
            label: Text(_currentStep == _steps.length - 1 ? 'SUBMIT' : 'NEXT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
              onSaved: (value) => _formData['Full Name'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
              onSaved: (value) => _formData['Phone Number'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: ListTile(
                title: const Text(
                  'Farm Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _farmLocation != null 
                      ? 'Lat: ${_farmLocation!.latitude.toStringAsFixed(4)}, Long: ${_farmLocation!.longitude.toStringAsFixed(4)}'
                      : 'Location not selected',
                  style: TextStyle(color: _farmLocation != null ? Colors.green.shade800 : Colors.grey),
                ),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Get Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      return;
                    }
            
                    LocationPermission permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        return;
                      }
                    }
            
                    if (permission == LocationPermission.deniedForever) {
                      return;
                    }
            
                    final position = await Geolocator.getCurrentPosition();
                    setState(() => _farmLocation = position);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Land Area (Acres)',
                prefixIcon: const Icon(Icons.landscape, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter land area' : null,
              onSaved: (value) => _formData['Land Area'] = value,
            ),
            const SizedBox(height: 16),
            _buildDropdown('Farming Type', _farmingTypes),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Years of Experience',
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter years of experience' : null,
              onSaved: (value) => _formData['Years of Experience'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String label, PlatformFile? file, Function(PlatformFile?) onFilePicked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          file?.name ?? 'No file selected',
          style: TextStyle(
            color: file != null ? Colors.green.shade800 : Colors.grey,
            fontStyle: file != null ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        trailing: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles();
            if (result != null) onFilePicked(result.files.first);
          },
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade800, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => _formData[label] = value,
      validator: (value) => value == null ? 'Please select $label' : null,
      icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade800),
      dropdownColor: Colors.white,
    );
  }

  void _continue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep += 1);
    } else {
      _submitForm();
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Registration Successful'),
            content: const Text('Your registration has been submitted successfully. We will review your details and get back to you soon.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/farmer_login');
                },
                child: const Text('Go to Login'),
              ),
            ],
          );
        },
      );
    }
  }
}
