/*import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class PlantAnalysisScreen extends StatefulWidget {
  const PlantAnalysisScreen({super.key});

  @override
  State<PlantAnalysisScreen> createState() => _PlantAnalysisScreenState();
}

class _PlantAnalysisScreenState extends State<PlantAnalysisScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _hasDisease = false; // Add this line
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  // Replace with your actual API key
  final String _apiKey = 'QAIljNdgAUdfqHs0SAdWxVr9BityAj03QWkghqXiUi0pCHBdxp';

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _analysisResult = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert image to base64
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Get current location (you can implement this or use fixed values)
      final double lat = 0.0; // Replace with actual latitude if available
      final double lng = 0.0; // Replace with actual longitude if available

      // Create request with JSON body instead of multipart
      final response = await http.post(
        Uri.parse('https://crop.kindwise.com/api/v1/identification'),
        headers: {'Content-Type': 'application/json', 'Api-Key': _apiKey},
        body: jsonEncode({
          "images": ["data:image/jpeg;base64,$base64Image"],
          "latitude": lat,
          "longitude": lng,
          "similar_images": true,
        }),
      );

      final jsonData = json.decode(response.body);

      // Debug the response
      print("Initial API Response: ${json.encode(jsonData)}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get identification details using the access token
        final accessToken = jsonData['access_token'];
        final identificationResponse = await http.get(
          Uri.parse(
            'https://crop.kindwise.com/api/v1/identification/$accessToken',
          ),
          headers: {'Api-Key': _apiKey},
        );

        if (identificationResponse.statusCode == 200) {
          final responseData = json.decode(identificationResponse.body);

          // Debug the response structure
          print("Detailed API Response: ${json.encode(responseData)}");

          // Safely extract suggestions with null checks and type checking
          List<dynamic> suggestions = [];

          try {
            if (responseData['result'] != null) {
              if (responseData['result']['disease'] is Map &&
                  responseData['result']['disease']['suggestions'] is List) {
                suggestions = responseData['result']['disease']['suggestions'];
              } else if (responseData['result']['classification'] is Map &&
                  responseData['result']['classification']['suggestions']
                      is List) {
                suggestions =
                    responseData['result']['classification']['suggestions'];
              }
            }
          } catch (e) {
            print("Error parsing suggestions: $e");
          }

          final bool hasDisease = suggestions.isNotEmpty;

          setState(() {
            _analysisResult = responseData;
            _isLoading = false;
            _hasDisease = hasDisease;
          });

          // Show toast message based on disease detection
          if (hasDisease) {
            Fluttertoast.showToast(
              msg: "Disease detected in your plant!",
              backgroundColor: Colors.red.shade700,
              textColor: Colors.white,
            );
          } else {
            Fluttertoast.showToast(
              msg: "No disease detected in your plant.",
              backgroundColor: Colors.green.shade700,
              textColor: Colors.white,
            );
          }
        } else {
          throw Exception('Failed to get identification details');
        }
      } else {
        throw Exception('Failed to analyze image: ${jsonData['message']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      Fluttertoast.showToast(
        msg: "Error analyzing image: ${e.toString()}",
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildPrecautionaryMeasures(String diseaseName) {
    // Map common plant diseases to their precautionary measures
    final Map<String, List<String>> precautionaryMeasures = {
      'Powdery Mildew': [
        'Remove and destroy infected plant parts',
        'Ensure good air circulation around plants',
        'Apply fungicides specifically designed for powdery mildew',
        'Avoid overhead watering to keep foliage dry',
        'Use resistant plant varieties when possible',
      ],
      'Leaf Spot': [
        'Remove infected leaves and destroy them',
        'Avoid overhead watering',
        'Ensure proper spacing between plants for air circulation',
        'Apply appropriate fungicide as recommended for your plant type',
        'Keep garden clean of plant debris',
      ],
      'Rust': [
        'Remove and destroy infected plant parts',
        'Apply fungicide early at first sign of disease',
        'Avoid wetting leaves when watering',
        'Ensure proper plant spacing',
        'Use rust-resistant varieties when available',
      ],
      'Blight': [
        'Remove and destroy all infected plant material',
        'Rotate crops annually',
        'Use disease-free seeds or plants',
        'Apply copper-based fungicides preventatively',
        'Avoid overhead irrigation',
      ],
      'Aphids': [
        'Spray plants with strong water stream to dislodge aphids',
        'Introduce natural predators like ladybugs',
        'Apply insecticidal soap or neem oil',
        'Remove heavily infested parts',
        'Use yellow sticky traps to monitor populations',
      ],
      'Spider Mites': [
        'Increase humidity around plants',
        'Spray plants with water regularly to discourage mites',
        'Apply miticide or insecticidal soap',
        'Introduce predatory mites',
        'Isolate infected plants to prevent spread',
      ],
      'Root Rot': [
        'Improve soil drainage',
        'Reduce watering frequency',
        'Repot plants with fresh, sterile potting mix',
        'Apply fungicide specifically for root diseases',
        'Ensure containers have drainage holes',
      ],
    };

    // Generic precautionary measures for unknown diseases
    final List<String> genericMeasures = [
      'Remove and destroy infected plant parts',
      'Ensure proper spacing between plants for good air circulation',
      'Avoid overhead watering to keep foliage dry',
      'Keep the garden clean of debris',
      'Consider applying a broad-spectrum fungicide or insecticide as appropriate',
      'Consult with a local plant expert or extension service for specific advice',
    ];

    // Get specific measures if available, otherwise use generic ones
    final measures =
        precautionaryMeasures.entries
            .where(
              (entry) =>
                  diseaseName.toLowerCase().contains(entry.key.toLowerCase()),
            )
            .map((e) => e.value)
            .firstOrNull ??
        genericMeasures;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          measures
              .map(
                (measure) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(measure)),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Analysis'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.eco, size: 48, color: Colors.green),
                        const SizedBox(height: 12),
                        const Text(
                          'Plant Disease Detector',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Take or select a photo of your plant to analyze for diseases',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSourceButton(
                              icon: Icons.camera_alt,
                              label: 'Camera',
                              onPressed: () => _getImage(ImageSource.camera),
                              color: Colors.blue,
                            ),
                            _buildImageSourceButton(
                              icon: Icons.photo_library,
                              label: 'Gallery',
                              onPressed: () => _getImage(ImageSource.gallery),
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_image != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _analyzeImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child:
                                  _isLoading
                                      ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text('Analyzing...'),
                                        ],
                                      )
                                      : const Text(
                                        'Analyze Plant',
                                        style: TextStyle(fontSize: 16),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (_analysisResult != null) _buildResultCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildAISearchButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToAISearch(String diseaseName, String searchType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AISearchScreen(
          diseaseName: diseaseName,
          searchType: searchType,
        ),
      ),
    );
  }

  Widget _buildResultCards() {
    // Safely extract suggestions with proper type checking
    List<dynamic> suggestions = [];

    try {
      if (_analysisResult?['result'] != null) {
        if (_analysisResult!['result']['disease'] is Map &&
            _analysisResult!['result']['disease']['suggestions'] is List) {
          suggestions = _analysisResult!['result']['disease']['suggestions'];
        } else if (_analysisResult!['result']['classification'] is Map &&
            _analysisResult!['result']['classification']['suggestions']
                is List) {
          suggestions =
              _analysisResult!['result']['classification']['suggestions'];
        }
      }
    } catch (e) {
      print("Error in _buildResultCards: $e");
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Analysis Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            if (suggestions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No diseases detected or plant not recognized.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];

                  // Safely extract values with type checking
                  String name = 'Unknown';
                  double probability = 0.0;
                  String? details;

                  if (suggestion is Map) {
                    if (suggestion['name'] is String) {
                      name = suggestion['name'];
                    }

                    if (suggestion['probability'] is num) {
                      probability =
                          (suggestion['probability'] as num).toDouble();
                    }

                    if (suggestion['details'] is String) {
                      details = suggestion['details'];
                    }
                  }

                  final confidence = (probability * 100).toStringAsFixed(0);

                  return ExpansionTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getConfidenceColor(probability),
                          radius: 16,
                          child: Text(
                            '$confidence%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (details != null) ...[
                              const Text(
                                'Details:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(details),
                              const SizedBox(height: 15),
                            ],
                            const Text(
                              'Precautionary Measures:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _buildPrecautionaryMeasures(name),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAISearchButton(
                                  icon: Icons.healing,
                                  label: 'Find Cure',
                                  onPressed: () => _navigateToAISearch(name, 'cure'),
                                  color: Colors.blue.shade700,
                                ),
                                _buildAISearchButton(
                                  icon: Icons.health_and_safety,
                                  label: 'Find Prevention',
                                  onPressed: () => _navigateToAISearch(name, 'prevention'),
                                  color: Colors.green.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double probability) {
    if (probability >= 0.7) {
      return Colors.green.shade700;
    } else if (probability >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
*/
