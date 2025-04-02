import 'package:flutter/material.dart';
// Remove string_extensions import
// import 'package:f2f/utils/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Add language provider import
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

  // Remove the unused positional parameter
  const ProductsScreen({super.key, required this.category});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _farmerId;
  String _farmerName = 'Loading...';
  bool _isLoading = true;
  bool isVegetableSection = true;
  final TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];

  final List<Product> fruits = [
    Product(
      name: 'Apple',
      imageUrl: 'assets/images/apple.png',
      price: 120,
      unit: 'kg',
    ),
    Product(
      name: 'Banana',
      imageUrl: 'assets/images/banana.png',
      price: 40,
      unit: 'dozen',
    ),
  ];

  final List<Product> vegetables = [
    Product(
      name: 'Tomato',
      imageUrl: 'assets/images/tomato.png',
      price: 30,
      unit: 'kg',
    ),
    Product(
      name: 'onion',
      imageUrl: 'assets/images/onion.png',
      price: 25,
      unit: 'kg',
    ),
  ];

  List<Product> get products => isVegetableSection ? vegetables : fruits;

  @override
  void initState() {
    super.initState();
    _getFarmerData();
    // Fix the category check
    isVegetableSection = widget.category == 'Vegetables';
    filteredProducts = List.from(products);
  }

  Future<void> _getFarmerData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _farmerId = user.uid;

        // First try to get from 'farmDetails'
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(_farmerId).get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>?;

          // Check multiple possible locations for the name
          if (data?['farmDetails']?['name'] != null) {
            _farmerName = data!['farmDetails']['name'];
          } else if (data?['name'] != null) {
            _farmerName = data!['name'];
          } else if (data?['displayName'] != null) {
            _farmerName = data!['displayName'];
          } else {
            _farmerName = 'No Name Found';
          }
        }

        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching farmer data: $e');
      setState(() {
        _farmerName = 'Error Loading Name';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            isTeluguSelected
                ? (widget.category == 'Vegetables' ? 'కూరగాయలు' : 'పండ్లు')
                : widget.category,
          ),
          backgroundColor: Colors.green.shade800,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        ],
      ),
      backgroundColor: Colors.green.shade50,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildProductList()),
          _buildSellButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Container(
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
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 10),
        ],
        border: Border.all(color: Colors.green.shade100, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildProductImage(product.imageUrl),
        title: Text(
          _getTranslatedProductName(product.name, isTeluguSelected),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle:
            product.selectedQuantity != null
                ? Text(
                  isTeluguSelected
                      ? '${product.selectedQuantity} ${_getTranslatedUnit(product.unit, isTeluguSelected)} వద్ద ₹${product.selectedPrice}/${_getTranslatedUnit(product.unit, isTeluguSelected)}'
                      : '${product.selectedQuantity} ${product.unit} at ₹${product.selectedPrice}/${product.unit}',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 14),
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
  }

  Widget _buildProductImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imageUrl,
        height: 80,
        width: 80,
        fit: BoxFit.fitHeight,
        errorBuilder:
            (context, error, stackTrace) => Container(
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
            ),
      ),
    );
  }

  Widget _buildSellButton() {
    // Get language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _processSale(context),
        icon:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : const Icon(Icons.sell, size: 24),
        label: Text(
          _isLoading
              ? (isTeluguSelected ? 'ప్రాసెసింగ్...' : 'Processing...')
              : (isTeluguSelected
                  ? 'ఎంచుకున్న వస్తువులను అమ్మండి'
                  : 'SELL SELECTED ITEMS'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _processSale(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    final soldItems =
        products
            .where(
              (product) =>
                  product.selectedQuantity != null &&
                  product.selectedPrice != null,
            )
            .map(
              (product) => {
                'name': product.name,
                'quantity': product.selectedQuantity,
                'unit': product.unit,
                'price': product.selectedPrice,
                'total': product.selectedQuantity! * product.selectedPrice!,
              },
            )
            .toList();

    if (soldItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTeluguSelected
                  ? 'దయచేసి కనీసం ఒక ఉత్పత్తికి పరిమాణం మరియు ధరను జోడించండి'
                  : 'Please add quantity and price for at least one product',
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final totalAmount = soldItems.fold(
        0.0,
        (sum, item) => sum + (item['total'] as double),
      );

      // Create sale document with farmer details
      await _firestore.collection('sales').add({
        'farmerId': _farmerId,
        'farmerName': _farmerName, // Using the properly fetched name
        'items': soldItems,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTeluguSelected
                  ? 'అమ్మకం విజయవంతంగా నమోదు చేయబడింది! మొత్తం: ₹$totalAmount'
                  : 'Sale recorded successfully! Total: ₹$totalAmount',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }

      // Reset selections
      setState(() {
        for (var product in products) {
          product.selectedQuantity = null;
          product.selectedPrice = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // In _processSale method
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTeluguSelected
                  ? 'సేల్ సేవ్ చేయడంలో లోపం: $e'
                  : 'Error saving sale: $e',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _showAddBottomSheet(BuildContext context, Product product) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    double quantity = 1.0;
    double price = product.price;
    String selectedUnit = product.unit;
    String? quantityError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
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
                  _buildUnitDropdown(setModalState, selectedUnit),
                  const SizedBox(height: 10),
                  _buildQuantityField(
                    setModalState,
                    selectedUnit,
                    quantityError,
                    (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null) {
                        if (selectedUnit == 'kg' && parsedValue > 5) {
                          setModalState(() {
                            quantityError = 'Maximum quantity is 5 kg';
                            quantity = 5.0;
                          });
                        } else if (selectedUnit == 'g' && parsedValue > 5000) {
                          setModalState(() {
                            quantityError = 'Maximum quantity is 5000 g';
                            quantity = 5000.0;
                          });
                        } else if (selectedUnit == 'dozen' &&
                            parsedValue > 10) {
                          setModalState(() {
                            quantityError = 'Maximum quantity is 10 dozen';
                            quantity = 10.0;
                          });
                        } else {
                          setModalState(() {
                            quantityError = null;
                            quantity = parsedValue;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPriceField(price, (value) {
                    setModalState(() => price = double.tryParse(value) ?? 0.0);
                  }, selectedUnit),
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

  Widget _buildUnitDropdown(StateSetter setModalState, String selectedUnit) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return DropdownButtonFormField<String>(
      value: selectedUnit,
      decoration: InputDecoration(
        labelText: isTeluguSelected ? 'యూనిట్ ఎంచుకోండి' : 'Select Unit',
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: 'kg',
          child: Text(
            isTeluguSelected ? 'కిలోగ్రాములు (కిలో)' : 'Kilograms (kg)',
          ),
        ),
        DropdownMenuItem(
          value: 'g',
          child: Text(isTeluguSelected ? 'గ్రాములు (గ్రా)' : 'Grams (g)'),
        ),
        DropdownMenuItem(
          value: 'dozen',
          child: Text(
            isTeluguSelected ? 'డజను (12 ముక్కలు)' : 'Dozen (12 pieces)',
          ),
        ),
      ],
      onChanged: (String? newValue) {
        setModalState(() {
          selectedUnit = newValue!;
        });
      },
    );
  }

  Widget _buildQuantityField(
    StateSetter setModalState,
    String selectedUnit,
    String? quantityError,
    Function(String) onChanged,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            isTeluguSelected
                ? 'పరిమాణం ($selectedUnit)'
                : 'Quantity ($selectedUnit)',
        border: const OutlineInputBorder(),
        errorText:
            quantityError != null
                ? (isTeluguSelected
                    ? _getTranslatedError(quantityError, selectedUnit)
                    : quantityError)
                : null,
        helperText:
            selectedUnit == 'kg'
                ? (isTeluguSelected ? 'గరిష్టం: 5 కిలో' : 'Maximum: 5 kg')
                : selectedUnit == 'g'
                ? (isTeluguSelected ? 'గరిష్టం: 5000 గ్రా' : 'Maximum: 5000 g')
                : (isTeluguSelected ? 'గరిష్టం: 10 డజను' : 'Maximum: 10 dozen'),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildPriceField(
    double price,
    Function(String) onChanged,
    String unit,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return TextField(
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: price.toString()),
      decoration: InputDecoration(
        labelText:
            isTeluguSelected
                ? 'ప్రతి ${_getTranslatedUnit(unit, isTeluguSelected)} ధర'
                : 'Price per $unit',
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  // Helper methods for translations
  String _getTranslatedProductName(String name, bool isTeluguSelected) {
    if (!isTeluguSelected) return name;

    switch (name.toLowerCase()) {
      case 'apple':
        return 'యాపిల్';
      case 'banana':
        return 'అరటిపండు';
      case 'tomato':
        return 'టమాటా';
      case 'onion':
        return 'ఉల్లిపాయ';
      default:
        return name;
    }
  }

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

  String _getTranslatedError(String error, String unit) {
    if (error.contains('Maximum quantity')) {
      if (unit == 'kg') {
        return 'గరిష్ట పరిమాణం 5 కిలో';
      } else if (unit == 'g') {
        return 'గరిష్ట పరిమాణం 5000 గ్రా';
      } else if (unit == 'dozen') {
        return 'గరిష్ట పరిమాణం 10 డజను';
      }
    }
    return error;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
