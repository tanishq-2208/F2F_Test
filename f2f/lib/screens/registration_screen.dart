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
      title: const Text('Personal'),
      content: _buildPersonalDetails(),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Farm'),
      content: _buildFarmDetails(),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Verification'),
      content: _buildVerificationDetails(),
      isActive: _currentStep >= 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Registration')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          steps: _steps,
          onStepContinue: _continue,
          onStepCancel: _cancel,
          controlsBuilder: _buildControls,
        ),
      ),
    );
  }

  Widget _buildVerificationDetails() {
    return Column(
      children: [
        _buildDocumentUpload('Farmer ID Document', _farmerIdDoc, (file) => setState(() => _farmerIdDoc = file)),
        _buildDocumentUpload('Farming Passbook', _passbookDoc, (file) => setState(() => _passbookDoc = file)),
        _buildDocumentUpload('Aadhar Card (Optional)', _aadharDoc, (file) => setState(() => _aadharDoc = file)),
TextFormField(
  decoration: InputDecoration(
    labelText: 'Bank Account Number',
    prefixIcon: Icon(Icons.account_balance),
    border: OutlineInputBorder(),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Please enter bank account number' : null,
  onSaved: (value) => _formData['Bank Account Number'] = value,
),
TextFormField(
  decoration: InputDecoration(
    labelText: 'Account Holder Name',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Please enter account holder name' : null,
  onSaved: (value) => _formData['Account Holder Name'] = value,
),
TextFormField(
  decoration: InputDecoration(
    labelText: 'Bank Name',
    prefixIcon: Icon(Icons.business),
    border: OutlineInputBorder(),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Please enter bank name' : null,
  onSaved: (value) => _formData['Bank Name'] = value,
),
TextFormField(
  decoration: InputDecoration(
    labelText: 'IFSC Code',
    prefixIcon: Icon(Icons.code),
    border: OutlineInputBorder(),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Please enter IFSC code' : null,
  onSaved: (value) => _formData['IFSC Code'] = value,
),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          if (_currentStep != 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('BACK'),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: details.onStepContinue,
            child: Text(_currentStep == _steps.length - 1 ? 'SUBMIT' : 'NEXT'),
          ),
        ],
      ),
    );
  }

  // In the state variables section, remove:
  // final List<String> _cropOptions = [...];
  // And any other crop-related variables
  
  // In _buildPersonalDetails(), remove image upload:
  Widget _buildPersonalDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
          onSaved: (value) => _formData['Full Name'] = value,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Phone Number',
          prefixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
        onSaved: (value) => _formData['Phone Number'] = value,
      ),
    ],
  );
}

// In _buildFarmDetails(), remove MultiSelectFormField and crops:
Widget _buildFarmDetails() {
  return Column(
    children: [
      ListTile(
        title: const Text('Farm Location'),
        subtitle: Text(_farmLocation != null 
            ? 'Lat: ${_farmLocation!.latitude}, Long: ${_farmLocation!.longitude}'
            : 'Location not selected'),
        trailing: IconButton(
          icon: const Icon(Icons.location_on),
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
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Land Area (Acres)',
          prefixIcon: Icon(Icons.landscape),
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) => value?.isEmpty ?? true ? 'Please enter land area' : null,
        onSaved: (value) => _formData['Land Area'] = value,
      ),
        _buildDropdown('Farming Type', _farmingTypes),
        // Remove entire MultiSelectFormField block
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Years of Experience',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter years of experience' : null,
          onSaved: (value) => _formData['Years of Experience'] = value,
        )
      ],
    );
  }



  Widget _buildDocumentUpload(String label, PlatformFile? file, Function(PlatformFile?) onFilePicked) {
    return ListTile(
      title: Text(label),
      subtitle: Text(file?.name ?? 'No file selected'),
      trailing: IconButton(
        icon: const Icon(Icons.attach_file),
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles();
          if (result != null) onFilePicked(result.files.first);
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => _formData[label] = value,
      validator: (value) => value == null ? 'Please select $label' : null,
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
      // Handle form submission with all collected data
    }
  }
}
