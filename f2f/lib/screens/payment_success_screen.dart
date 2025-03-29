import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;
    
    // Get arguments
    final Map<String, dynamic> args = 
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? 
        {'orderId': 'Unknown', 'paymentId': 'Unknown'};
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: width * 0.3,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade800,
                    size: width * 0.2,
                  ),
                ),
                
                SizedBox(height: height * 0.04),
                
                // Success message
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                
                SizedBox(height: height * 0.02),
                
                Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                SizedBox(height: height * 0.04),
                
                // Order details
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(width * 0.03),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context, 
                        'Order ID', 
                        args['orderId'],
                        width,
                      ),
                      SizedBox(height: height * 0.015),
                      _buildDetailRow(
                        context, 
                        'Payment ID', 
                        args['paymentId'],
                        width,
                      ),
                      SizedBox(height: height * 0.015),
                      _buildDetailRow(
                        context, 
                        'Date', 
                        DateTime.now().toString().substring(0, 16),
                        width,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: height * 0.06),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/my_orders');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.green.shade800),
                          padding: EdgeInsets.symmetric(vertical: height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                        ),
                        child: Text(
                          'View Orders',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/customer_home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          padding: EdgeInsets.symmetric(vertical: height * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                        ),
                        child: Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.04,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}