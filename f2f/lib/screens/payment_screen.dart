import 'package:f2f/screens/payment_success_screen.dart';
import 'package:f2f/services/order_service.dart';
import 'package:f2f/services/wallet_service.dart';
import 'package:f2f/services/user_service.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';

class PaymentScreen extends StatefulWidget {
  final String productName;
  final double productPrice;
  final String productImage;
  final int availableQuantity;
  final String? farmerId; // Add this parameter
  final int? quantity; // Add this parameter

  const PaymentScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.availableQuantity,
    this.farmerId, // Add to constructor
    this.quantity,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int quantity = 1;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false; // Add this variable
  String _paymentMethod = 'Wallet'; // Default payment method
  bool _isLoadingAddress = true; // Add this variable
  final UserService _userService = UserService(); // Add this service

  @override
  void initState() {
    super.initState();
    // Set quantity from widget if provided
    if (widget.quantity != null) {
      quantity = widget.quantity!;
    }
    // Load saved address
    _loadSavedAddress();
  }

  // Add this method to load saved address
  Future<void> _loadSavedAddress() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final addressData = await _userService.getUserAddress(userId);

        if (addressData != null) {
          setState(() {
            _addressController.text = addressData['street'] ?? '';
            _cityController.text = addressData['city'] ?? '';
            _stateController.text = addressData['state'] ?? '';
            _zipController.text = addressData['zipCode'] ?? '';
            _phoneController.text = addressData['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading address: $e');
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  // Add this method to save address
  Future<void> _saveAddress() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _userService.saveUserAddress(userId, {
          'street': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zipCode': _zipController.text,
          'phone': _phoneController.text,
        });
      }
    } catch (e) {
      print('Error saving address: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _launchRazorpay() async {
    // Save address before proceeding with payment
    await _saveAddress();

    final Uri url = Uri.parse('https://rzp.io/rzp/0e06EW39');

    if (await canLaunchUrl(url)) {
      // Launch the URL and wait for it to complete
      final result = await launchUrl(url, mode: LaunchMode.externalApplication);

      if (result) {
        // This is a simplification since we can't actually detect payment success from the URL launch
        // In a real app, you would implement a webhook or callback from Razorpay

        // Create the order in Firestore
        final orderService = OrderService();
        final fullAddress =
            '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_zipController.text}';

        try {
          final orderId = await orderService.createOrder(
            productName: widget.productName,
            productPrice: widget.productPrice,
            quantity: quantity,
            productImage: widget.productImage,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            zipCode: _zipController.text,
            phone: _phoneController.text,
            farmerId:
                widget.farmerId ?? '', // Pass the farmerId with null check
          );

          // Navigate to success screen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentSuccessScreen(
                    productName: widget.productName,
                    productPrice: widget.productPrice,
                    quantity: quantity,
                    deliveryAddress: fullAddress,
                    orderId: orderId,
                    farmerId: widget.farmerId ?? '', // Add null check here too
                  ),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating order: $e')));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment process was interrupted')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch payment page')),
      );
    }
  }

  // Add this method to process wallet payment
  Future<void> _processWalletPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Save address before proceeding with payment
    await _saveAddress();

    // Calculate total amount
    final totalAmount =
        widget.productPrice * quantity + 40; // Include delivery fee

    // Check if wallet has enough balance
    final walletService = WalletService();
    final hasEnough = await walletService.hasEnoughBalance(totalAmount);

    if (!hasEnough) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Insufficient wallet balance. Please add money to your wallet.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      // Navigate to wallet screen
      if (!mounted) return;
      Navigator.pushNamed(context, '/wallet');
      return;
    }

    // Deduct amount from wallet
    final description = 'Purchase: ${widget.productName} x $quantity';
    await walletService.deductAmount(totalAmount, description);

    // Create the order in Firestore
    final orderService = OrderService();
    final fullAddress =
        '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_zipController.text}';

    try {
      final orderId = await orderService.createOrder(
        productName: widget.productName,
        productPrice: widget.productPrice,
        quantity: quantity,
        productImage: widget.productImage,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        phone: _phoneController.text,
        farmerId: widget.farmerId ?? '',
      );

      // Navigate to success screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentSuccessScreen(
                productName: widget.productName,
                productPrice: widget.productPrice,
                quantity: quantity,
                deliveryAddress: fullAddress,
                orderId: orderId,
                farmerId: widget.farmerId ?? '',
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.productPrice * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body:
          _isLoadingAddress
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product summary
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(widget.productImage),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.productName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${widget.productPrice.toStringAsFixed(2)} per unit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quantity selector
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (quantity > 1) {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: Colors.green[700],
                                    iconSize: 32,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (quantity < widget.availableQuantity) {
                                        setState(() {
                                          quantity++;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cannot exceed available quantity',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    color:
                                        quantity < widget.availableQuantity
                                            ? Colors.green[700]
                                            : Colors.grey[400],
                                    iconSize: 32,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Available: ${widget.availableQuantity} units',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        widget.availableQuantity < 5
                                            ? Colors.red
                                            : Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery address
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Address'),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _saveAddress();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Address saved successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Rest of the address form remains the same
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Street Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your city';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _stateController,
                                      decoration: const InputDecoration(
                                        labelText: 'State',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your state';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _zipController,
                                      decoration: const InputDecoration(
                                        labelText: 'ZIP Code',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter ZIP code';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                  prefixText: '+91 ',
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Order summary
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal ($quantity items)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '₹${totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Fee',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const Text(
                                    '₹40.00',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${(totalPrice + 40).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),

                              // Add payment method selection
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('Wallet'),
                                      value: 'Wallet',
                                      groupValue: _paymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          _paymentMethod = value!;
                                        });
                                      },
                                      activeColor: Colors.green[700],
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: const Text('Razorpay'),
                                      value: 'Razorpay',
                                      groupValue: _paymentMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          _paymentMethod = value!;
                                        });
                                      },
                                      activeColor: Colors.green[700],
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pay now button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isProcessing
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_paymentMethod == 'Wallet') {
                                        _processWalletPayment();
                                      } else {
                                        _launchRazorpay();
                                      }
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child:
                              _isProcessing
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Pay Now',
                                    style: TextStyle(fontSize: 18),
                                  ),
                        ),
                      ),

                      // Add wallet balance display
                      FutureBuilder<double>(
                        future: WalletService().getBalance(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && _paymentMethod == 'Wallet') {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Current wallet balance: ₹${snapshot.data!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  } // Close the build method
} // Close the _PaymentScreenState class
