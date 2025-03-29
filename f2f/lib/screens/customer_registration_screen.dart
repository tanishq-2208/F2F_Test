import 'package:flutter/material.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  int _currentStep = 0;

  List<Step> get _steps => [
    Step(
      title: const Text('Personal'),
      content: _buildPersonalDetails(),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Verification'),
      content: _buildVerificationDetails(),
      isActive: _currentStep >= 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Registration')),
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

  Widget _buildPersonalDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
          onSaved: (value) => _formData['Full Name'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
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

  Widget _buildVerificationDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (value) => _formData['Email'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a password';
            }
            if (value!.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          onSaved: (value) => _formData['Password'] = value,
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
      print(_formData); // For testing, replace with actual submission logic
    }
  }
}