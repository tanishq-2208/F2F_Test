import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart';

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

class ProductsScreen extends StatefulWidget {
  final String category;

  const ProductsScreen({super.key, required this.category});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
    // Set isVegetableSection based on the category passed
    isVegetableSection = widget.category == 'Vegetables';
    filteredProducts = List.from(products);
  }

  // Update AppBar in build method
  @override
  Widget build(BuildContext context) {
    // Get language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTeluguSelected
              ? (widget.category == 'Vegetables' ? 'కూరగాయలు' : 'పండ్లు')
              : widget.category,
        ),
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
              isVegetableSection
                  ? (isTeluguSelected ? 'పండ్లు చూపించు' : 'Show Fruits')
                  : (isTeluguSelected ? 'కూరగాయలు చూపించు' : 'Show Vegetables'),
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
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                    isTeluguSelected
                        ? 'ఉత్పత్తులను శోధించండి...'
                        : 'Search products...',
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
                      _getTranslatedProductName(product.name, isTeluguSelected),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        product.selectedQuantity != null
                            ? Text(
                              isTeluguSelected
                                  ? '${product.selectedQuantity} ${_getTranslatedUnit(product.unit, isTeluguSelected)} వద్ద ₹${product.selectedPrice}/${_getTranslatedUnit(product.unit, isTeluguSelected)}'
                                  : '${product.selectedQuantity} ${product.unit} at ₹${product.selectedPrice}/${product.unit}',
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
                _processSale(context);
              },
              icon: const Icon(Icons.sell, size: 24),
              label: Text(
                isTeluguSelected
                    ? 'ఎంచుకున్న వస్తువులను అమ్మండి'
                    : 'SELL SELECTED ITEMS',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  void _processSale(BuildContext context) {
    // Get language provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    double totalAmount = 0;
    bool hasSelectedProducts = false;

    for (var product in products) {
      if (product.selectedQuantity != null && product.selectedPrice != null) {
        totalAmount += product.selectedQuantity! * product.selectedPrice!;
        hasSelectedProducts = true;
      }
    }

    if (hasSelectedProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTeluguSelected
                ? 'మొత్తం అమ్మకపు మొత్తం: ₹$totalAmount'
                : 'Total Sale Amount: ₹$totalAmount',
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
          content: Text(
            isTeluguSelected
                ? 'దయచేసి కనీసం ఒక ఉత్పత్తికి పరిమాణం మరియు ధరను జోడించండి'
                : 'Please add quantity and price for at least one product',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddBottomSheet(BuildContext context, Product product) {
    // Get language provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

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
                    quantityError =
                        isTeluguSelected
                            ? 'గరిష్ట పరిమాణం 5 కిలోలు'
                            : 'Maximum quantity is 5 kg';
                    quantity = 5.0;
                  });
                } else if (selectedUnit == 'g' && parsedValue > 5000) {
                  setModalState(() {
                    quantityError =
                        isTeluguSelected
                            ? 'గరిష్ట పరిమాణం 5000 గ్రాములు'
                            : 'Maximum quantity is 5000 g';
                    quantity = 5000.0;
                  });
                } else if (selectedUnit == 'dozen' && parsedValue > 10) {
                  setModalState(() {
                    quantityError =
                        isTeluguSelected
                            ? 'గరిష్ట పరిమాణం 10 డజన్లు'
                            : 'Maximum quantity is 10 dozen';
                    quantity = 10.0;
                  });
                } else {
                  setModalState(() {
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
                    _getTranslatedProductName(product.name, isTeluguSelected),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: InputDecoration(
                      labelText:
                          isTeluguSelected ? 'యూనిట్ ఎంచుకోండి' : 'Select Unit',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text(
                          isTeluguSelected
                              ? 'కిలోగ్రాములు (కిలో)'
                              : 'Kilograms (kg)',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'g',
                        child: Text(
                          isTeluguSelected ? 'గ్రాములు (గ్రా)' : 'Grams (g)',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'dozen',
                        child: Text(
                          isTeluguSelected
                              ? 'డజను (12 ముక్కలు)'
                              : 'Dozen (12 pieces)',
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setModalState(() {
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
                      labelText:
                          isTeluguSelected
                              ? 'పరిమాణం ($selectedUnit)'
                              : 'Quantity ($selectedUnit)',
                      border: const OutlineInputBorder(),
                      errorText: quantityError,
                      helperText:
                          selectedUnit == 'kg'
                              ? (isTeluguSelected
                                  ? 'గరిష్టం: 5 కిలో'
                                  : 'Maximum: 5 kg')
                              : selectedUnit == 'g'
                              ? (isTeluguSelected
                                  ? 'గరిష్టం: 5000 గ్రా'
                                  : 'Maximum: 5000 g')
                              : (isTeluguSelected
                                  ? 'గరిష్టం: 10 డజన్లు'
                                  : 'Maximum: 10 dozen'),
                    ),
                    onChanged: validateQuantity,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          isTeluguSelected
                              ? 'ప్రతి $selectedUnit ధర'
                              : 'Price per $selectedUnit',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
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
                    child: Text(isTeluguSelected ? 'సరే' : 'OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to translate product names
  String _getTranslatedProductName(String name, bool isTeluguSelected) {
    if (!isTeluguSelected) return name;

    switch (name) {
      case 'Apple':
        return 'యాపిల్';
      case 'Banana':
        return 'అరటిపండు';
      case 'Tomato':
        return 'టమాటా';
      case 'Onion':
        return 'ఉల్లిపాయ';
      default:
        return name;
    }
  }

  // Helper method to translate units
  String _getTranslatedUnit(String unit, bool isTeluguSelected) {
    if (!isTeluguSelected) return unit;

    switch (unit) {
      case 'kg':
        return 'కిలో';
      case 'g':
        return 'గ్రా';
      case 'dozen':
        return 'డజను';
      default:
        return unit;
    }
  }
}
