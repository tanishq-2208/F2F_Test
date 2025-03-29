import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  
  const PaymentScreen({
    Key? key, 
    required this.amount,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isPaymentProcessing = false;
  String _selectedPaymentMethod = 'card'; // Default selected payment method

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    Fluttertoast.showToast(
      msg: "Payment Successful: ${response.paymentId}",
      toastLength: Toast.LENGTH_LONG,
    );
    
    // Navigate to success screen
    Navigator.pushReplacementNamed(
      context, 
      '/payment_success',
      arguments: {
        'orderId': widget.orderId,
        'paymentId': response.paymentId,
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    Fluttertoast.showToast(
      msg: "External Wallet Selected: ${response.walletName}",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _startPayment() {
    setState(() {
      _isPaymentProcessing = true;
    });
    
    var options = {
      'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your Razorpay key
      'amount': widget.amount * 100, // Amount in smallest currency unit (paise for INR)
      'name': 'Farm2Fork Connect',
      'description': 'Order #${widget.orderId}',
      'prefill': {
        'contact': '9876543210', // Replace with user's phone
        'email': 'user@example.com', // Replace with user's email
      },
      'external': {
        'wallets': ['paytm', 'freecharge', 'amazonpay', 'mobikwik', 'olamoney']
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true
      },
      'config': {
        'display': {
          'hide': [],
          'preferences': {
            'show_default_blocks': true
          },
          'blocks': {
            'banks': {
              'name': 'Pay via UPI or Cards',
              'instruments': [
                {
                  'method': 'upi',
                  'apps': ['google_pay', 'phonepe', 'paytm', 'cred']
                },
                {
                  'method': 'card'
                },
                {
                  'method': 'wallet',
                  'wallets': ['paytm', 'amazonpay', 'freecharge']
                }
              ]
            }
          }
        }
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isPaymentProcessing = false;
      });
      debugPrint('Error: $e');
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order summary card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order ID:',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            widget.orderId,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Divider(),
                      SizedBox(height: height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${widget.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: height * 0.04),
              
              // Payment methods
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),
              
              // Updated Payment options with functional radio buttons
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.01,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          size: width * 0.07,
                          color: Colors.blue.shade700,
                        ),
                        title: Text(
                          'Credit/Debit Card',
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        trailing: Radio(
                          value: 'card',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value.toString();
                            });
                          },
                          activeColor: Colors.green.shade800,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'card';
                          });
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.account_balance,
                          size: width * 0.07,
                          color: Colors.green.shade700,
                        ),
                        title: Text(
                          'UPI',
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        trailing: Radio(
                          value: 'upi',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value.toString();
                            });
                          },
                          activeColor: Colors.green.shade800,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'upi';
                          });
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.account_balance_wallet,
                          size: width * 0.07,
                          color: Colors.purple.shade700,
                        ),
                        title: Text(
                          'Wallet',
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        trailing: Radio(
                          value: 'wallet',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value.toString();
                            });
                          },
                          activeColor: Colors.green.shade800,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'wallet';
                          });
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.account_balance_outlined,
                          size: width * 0.07,
                          color: Colors.orange.shade700,
                        ),
                        title: Text(
                          'Net Banking',
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        trailing: Radio(
                          value: 'netbanking',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value.toString();
                            });
                          },
                          activeColor: Colors.green.shade800,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'netbanking';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Display UPI apps when UPI is selected
              if (_selectedPaymentMethod == 'upi')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.03),
                    Text(
                      'Popular UPI Apps',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUpiAppIcon('Google Pay', 'assets/gpay.png', width),
                        _buildUpiAppIcon('PhonePe', 'assets/phonepe.png', width),
                        _buildUpiAppIcon('Paytm', 'assets/paytm.png', width),
                        _buildUpiAppIcon('CRED', 'assets/cred.png', width),
                      ],
                    ),
                    
                    // Add UPI ID input section
                    SizedBox(height: height * 0.03),
                    Text(
                      'Or Pay Using UPI ID',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.01,
                        ),
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your UPI ID (e.g. mobile@upi)',
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.account_balance,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              'A payment request will be sent to this UPI ID',
                              style: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Display wallet options when wallet is selected
              if (_selectedPaymentMethod == 'wallet')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.03),
                    Text(
                      'Select Wallet',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWalletIcon('Paytm', 'assets/paytm.png', width),
                        _buildWalletIcon('Amazon Pay', 'assets/amazonpay.png', width),
                      ],
                    ),
                  ],
                ),
              
              SizedBox(height: height * 0.04),
              
              // Payment button
              ElevatedButton(
                onPressed: _isPaymentProcessing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isPaymentProcessing
                    ? SizedBox(
                        height: width * 0.06,
                        width: width * 0.06,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'Pay ₹${widget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              SizedBox(height: height * 0.02),
              
              // Secure payment note
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: width * 0.04,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: width * 0.01),
                    Text(
                      'Secure Payment via Razorpay',
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build UPI app icons
  Widget _buildUpiAppIcon(String name, String imagePath, double width) {
    return Column(
      children: [
        Container(
          width: width * 0.15,
          height: width * 0.15,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(width * 0.02),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            Icons.payment,
            size: width * 0.08,
            color: Colors.blue.shade700,
          ),
          // For actual implementation, use Image.asset instead:
          // child: Image.asset(imagePath, width: width * 0.1),
        ),
        SizedBox(height: width * 0.01),
        Text(
          name,
          style: TextStyle(fontSize: width * 0.03),
        ),
      ],
    );
  }
  
  // Helper method to build wallet icons
  Widget _buildWalletIcon(String name, String imagePath, double width) {
    return Column(
      children: [
        Container(
          width: width * 0.15,
          height: width * 0.15,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(width * 0.02),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: width * 0.08,
            color: Colors.purple.shade700,
          ),
          // For actual implementation, use Image.asset instead:
          // child: Image.asset(imagePath, width: width * 0.1),
        ),
        SizedBox(height: width * 0.01),
        Text(
          name,
          style: TextStyle(fontSize: width * 0.03),
        ),
      ],
    );
  }
}