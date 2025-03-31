import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // OTP related variables
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isVerifying = false;
  String? _verificationId;
  int? _resendToken;
  String? _phoneNumber;
  
  Position? _farmLocation;
  PlatformFile? _farmerIdDoc;
  PlatformFile? _passbookDoc;
  PlatformFile? _aadharDoc;

  final List<String> _farmingTypes = ['Vegetables', 'Fruits'];

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
      title: const Text('Bank Details', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildBankDetails(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Verify OTP', style: TextStyle(fontWeight: FontWeight.bold)),
      content: _buildOtpVerification(),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
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

  void _continue() {
    // Don't validate the entire form, just proceed to next step
    if (_currentStep < _steps.length - 1) {
      // Save any data entered so far
      _formKey.currentState!.save();
      
      setState(() => _currentStep += 1);
      
      // If moving to OTP step, send OTP automatically
      if (_currentStep == 3 && !_isOtpSent) {
        _sendOtp();
      }
    } else {
      // Validate and submit on final step
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _submitForm();
      }
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
              onSaved: (value) {
                _formData['Phone Number'] = value;
                _phoneNumber = '+91${value!.trim()}'; // Ensure proper formatting
              },
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

  Widget _buildBankDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildOtpVerification() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We have sent a verification code to your phone number. Please enter the code below to verify your account.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: const Icon(Icons.security, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter the OTP' : null,
            ),
            const SizedBox(height: 16),
            if (!_isOtpSent)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _sendOtp,
                  icon: _isVerifying 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isVerifying ? 'Sending...' : 'Send OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: TextButton.icon(
                  onPressed: _isVerifying ? null : _resendOtp,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resend OTP'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade800,
                  ),
                ),
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

  Future<void> _sendOtp() async {
    // Ensure phone number is properly formatted
    if (_formData['Phone Number'] == null || _formData['Phone Number']!.isEmpty) {
      setState(() => _currentStep = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number first')),
      );
      return;
    }

    // Format phone number with country code
    _phoneNumber = '+91${_formData['Phone Number']!.trim()}';
    
    // Validate phone number format
    if (!RegExp(r'^\+91[0-9]{10}$').hasMatch(_phoneNumber!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit Indian phone number')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            _isVerifying = false;
            _isOtpSent = true;
            _otpController.text = credential.smsCode ?? '';
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isVerifying = false);
          String errorMessage = 'Verification failed (${e.code}). Please try again.';
          
          // Enhanced error mapping
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format. Please enter a valid 10-digit Indian number.';
              break;
            case 'quota-exceeded':
              errorMessage = 'Daily OTP limit reached. Try again tomorrow.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts. Please wait before trying again.';
              break;
            case 'app-not-authorized':
              errorMessage = 'App not configured for phone auth. Contact support.';
              break;
            case 'missing-client-identifier':
              errorMessage = 'Firebase configuration issue. Reinstall app.';
              break;
          }
          
          // Log the full error for debugging
          debugPrint('OTP Error: ${e.code} - ${e.message}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isVerifying = false;
            _isOtpSent = true;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully!')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      debugPrint('OTP Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error occurred. Please try again.')),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isVerifying = true);
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            _isVerifying = false;
            _otpController.text = credential.smsCode ?? '';
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isVerifying = false);
          String errorMessage = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'OTP quota exceeded. Try again later.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isVerifying = false;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully!')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_otpController.text.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
        );
        return;
      }

      setState(() => _isVerifying = true);
      
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otpController.text,
        );
        
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        Map<String, dynamic> userData = {
          'name': _formData['Full Name'],
          'phoneNumber': _formData['Phone Number'],
          'role': widget.role,
          'farmDetails': {
            'location': _farmLocation != null ? 
                GeoPoint(_farmLocation!.latitude, _farmLocation!.longitude) : null,
            'landArea': _formData['Land Area'],
            'farmingType': _formData['Farming Type'],
            'yearsOfExperience': _formData['Years of Experience'],
          },
          'bankDetails': {
            'accountNumber': _formData['Bank Account Number'],
            'accountHolderName': _formData['Account Holder Name'],
            'bankName': _formData['Bank Name'],
            'ifscCode': _formData['IFSC Code'],
          },
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);
        
        setState(() => _isVerifying = false);
        
        showDialog(
          context: context,
          barrierDismissible: false,
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
      } on FirebaseAuthException catch (e) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.message}')),
        );
      } catch (e) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}