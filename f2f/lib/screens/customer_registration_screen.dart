import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  int _currentStep = 0;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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
      appBar: AppBar(
        title: const Text('Customer Registration'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
          onSaved: (value) => _formData['Address'] = value,
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
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please confirm your password';
            }
            if (value != _formData['Password']) {
              return 'Passwords do not match';
            }
            return null;
          },
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
    final isLastStep = _currentStep == _steps.length - 1;

    if (isLastStep) {
      _submitForm();
    } else {
      // For the first step (Personal Details)
      if (_currentStep == 0) {
        // Save the current form data
        _formKey.currentState?.save();
        setState(() {
          _currentStep += 1;
        });
      }
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        // Create user account with email and password
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _formData['Email'],
          password: _formData['Password'],
        );

        // Store additional user details in Firestore
        await _firestore.collection('customers').doc(userCredential.user!.uid).set({
          'fullName': _formData['Full Name'],
          'phoneNumber': _formData['Phone Number'],
          'address': _formData['Address'],
          'email': _formData['Email'],
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'customer',
        });

        // Show success message and navigate
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to customer home screen
          Navigator.pushReplacementNamed(context, '/customer_home');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Registration failed';
        
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for this email';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Please enter a valid email address';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}