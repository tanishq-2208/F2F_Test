import 'package:flutter/material.dart';

class Product {
  final String name;
  final String imageUrl;
  double price;
  String unit;
  double? selectedQuantity;
  double? selectedPrice;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.unit,
    this.selectedQuantity,
    this.selectedPrice,
  });
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool isVegetableSection = false;

  final List<Product> fruits = [
    Product(
      name: 'Apple',
      imageUrl: 'assets/images/apple.png',
      price: 0.0,
      unit: 'kg',
    ),
    Product(
      name: 'Banana',
      imageUrl: 'assets/images/banana.png',
      price: 0.0,
      unit: 'kg',
    ),
  ];

  final List<Product> vegetables = [
    Product(
      name: 'Tomato',
      imageUrl: 'assets/images/tomato.png',
      price: 0.0,
      unit: 'kg',
    ),
    Product(
      name: 'Onion',
      imageUrl: 'assets/images/onion.png',
      price: 0.0,
      unit: 'kg',
    ),
  ];

  List<Product> get products => isVegetableSection ? vegetables : fruits;
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);
  }

  // Update AppBar in build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isVegetableSection ? 'Vegetables' : 'Fruits'),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                isVegetableSection = !isVegetableSection;
                searchController.clear();
                filteredProducts = List.from(products);
              });
            },
            icon: Icon(
              isVegetableSection ? Icons.apple : Icons.eco,
              color: Colors.white,
            ),
            label: Text(
              isVegetableSection ? 'Show Fruits' : 'Show Vegetables',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.green.shade50,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            // Update the search TextField in the build method:
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.green.shade800),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green.shade800),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filteredProducts =
                      products
                          .where(
                            (product) => product.name.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(color: Colors.green.shade100, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        product.imageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.green.shade800,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    subtitle:
                        product.selectedQuantity != null
                            ? Text(
                              '${product.selectedQuantity} ${product.unit} at ₹${product.selectedPrice}/${product.unit}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            )
                            : null,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.green.shade800,
                        size: 30,
                      ),
                      onPressed: () => _showAddBottomSheet(context, product),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                double totalAmount = 0;
                bool hasSelectedProducts = false;

                for (var product in products) {
                  if (product.selectedQuantity != null &&
                      product.selectedPrice != null) {
                    totalAmount +=
                        product.selectedQuantity! * product.selectedPrice!;
                    hasSelectedProducts = true;
                  }
                }

                if (hasSelectedProducts) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Total Sale Amount: ₹$totalAmount',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green.shade800,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  setState(() {
                    for (var product in products) {
                      product.selectedQuantity = null;
                      product.selectedPrice = null;
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please add quantity and price for at least one product',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red.shade800,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.sell, size: 24),
              label: const Text(
                'SELL SELECTED ITEMS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context, Product product) {
    double quantity = 1.0;
    double price = 0.0;
    String selectedUnit = product.unit;
    String? quantityError;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void validateQuantity(String value) {
              double? parsedValue = double.tryParse(value);
              if (parsedValue != null) {
                if (selectedUnit == 'kg' && parsedValue > 5) {
                  setModalState(() {
                    // Changed from setState to setModalState
                    quantityError = 'Maximum quantity is 5 kg';
                    quantity = 5.0;
                  });
                } else if (selectedUnit == 'g' && parsedValue > 5000) {
                  setModalState(() {
                    // Changed from setState to setModalState
                    quantityError = 'Maximum quantity is 5000 g';
                    quantity = 5000.0;
                  });
                } else if (selectedUnit == 'dozen' && parsedValue > 10) {
                  setModalState(() {
                    // Changed from setState to setModalState
                    quantityError = 'Maximum quantity is 10 dozen';
                    quantity = 10.0;
                  });
                } else {
                  setModalState(() {
                    // Changed from setState to setModalState
                    quantityError = null;
                    quantity = parsedValue;
                  });
                }
              }
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Select Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text('Kilograms (kg)'),
                      ),
                      DropdownMenuItem(value: 'g', child: Text('Grams (g)')),
                      DropdownMenuItem(
                        value: 'dozen',
                        child: Text('Dozen (12 pieces)'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setModalState(() {
                        // Changed from setState to setModalState
                        selectedUnit = newValue!;
                        quantity = 1.0;
                        quantityError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity ($selectedUnit)',
                      border: const OutlineInputBorder(),
                      errorText: quantityError,
                      helperText:
                          selectedUnit == 'kg'
                              ? 'Maximum: 5 kg'
                              : selectedUnit == 'g'
                              ? 'Maximum: 5000 g'
                              : 'Maximum: 10 dozen',
                    ),
                    onChanged: validateQuantity,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price per $selectedUnit',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        // Changed from setState to setModalState
                        price = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        product.selectedQuantity = quantity;
                        product.selectedPrice = price;
                        product.unit = selectedUnit;
                        filteredProducts = List.from(products);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
