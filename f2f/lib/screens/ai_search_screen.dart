import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
//simport 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:f2f/providers/language_provider.dart';

class AISearchScreen extends StatefulWidget {
  final String diseaseName;
  final String searchType;
  final File? selectedImage;

  const AISearchScreen({
    super.key,
    required this.diseaseName,
    required this.searchType,
    this.selectedImage,
  });

  @override
  State<AISearchScreen> createState() => _AISearchScreenState();
}

class _AISearchScreenState extends State<AISearchScreen> {
  bool _isLoading = true;
  String _responseText = 'Loading...';
  bool _isTranslated = false;

  // API key for Google's Generative AI - make sure this is correct
  final String apiKey = 'AIzaSyC5z66xReuvUk1jOXcipuUIvB_u52Mnkl8';

  @override
  void initState() {
    super.initState();
    _fetchAIResponse();
  }

  Future<void> _fetchAIResponse() async {
    setState(() {
      _isLoading = true;
      _responseText = 'Loading...';
      _isTranslated = false;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

      // Use the correct model name for Gemini API
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

      // Construct a detailed prompt based on the disease and search type
      String prompt;
      if (isTeluguSelected) {
        prompt =
            '${widget.searchType == 'cure' ? 'Find the cure of' : 'Find prevention methods for'} ${widget.diseaseName} plant disease. Please provide detailed information including treatments, methods, and best practices. Translate the entire response to Telugu language.';
        _isTranslated = true;
      } else {
        prompt =
            '${widget.searchType == 'cure' ? 'Find the cure of' : 'Find prevention methods for'} ${widget.diseaseName} plant disease. Please provide detailed information including treatments, methods, and best practices.';
      }

      // Send a direct content generation request instead of chat
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;

      setState(() {
        _isLoading = false;
        _responseText = text ?? 'No response received';
      });

      if (text == null) {
        _showError('Empty response from AI.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseText = 'Error: $e';
      });
      _showError('AI Error: $e');
    }
  }

  Future<void> _translateContent() async {
    if (_isTranslated) return; // Already translated

    setState(() {
      _isLoading = true;
      _responseText = 'Translating to Telugu...';
    });

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

      final prompt =
          'Translate the following text to Telugu language: $_responseText';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;

      setState(() {
        _isLoading = false;
        _responseText = text ?? 'Translation failed';
        _isTranslated = true;
      });

      if (text == null) {
        _showError('Empty translation response.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseText += '\n\nTranslation error: $e';
      });
      _showError('Translation Error: $e');
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /* Future<void> _launchInBrowser() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    String queryLang = isTeluguSelected ? ' తెలుగులో' : '';
    final query = Uri.encodeComponent(widget.diseaseName);
    final url = Uri.parse('https://www.google.com/search?q=$query');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      _showError('Could not launch browser: $e');
    }
  }*/

  Widget _buildRoundedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(label, style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTeluguSelected = languageProvider.selectedLanguage == 'te';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isTeluguSelected
              ? '${widget.diseaseName} కోసం ${widget.searchType == 'cure' ? 'చికిత్స' : 'నివారణ'}'
              : '${widget.searchType.capitalize()} for ${widget.diseaseName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff1A5319),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAIResponse,
          ),
          if (!_isTranslated && !isTeluguSelected)
            IconButton(
              icon: const Icon(Icons.translate),
              onPressed: _translateContent,
              tooltip: 'Translate to Telugu',
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1A5319), Color(0xff0A2A10)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              if (widget.selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    widget.selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTeluguSelected
                          ? 'వ్యాధి: ${widget.diseaseName}'
                          : 'Disease: ${widget.diseaseName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTeluguSelected
                          ? 'శోధన రకం: ${widget.searchType == 'cure' ? 'చికిత్స' : 'నివారణ'}'
                          : 'Search Type: ${widget.searchType.capitalize()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffD6EFD8),
                    border: Border.all(color: Colors.black12.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MarkdownBody(
                      data: _responseText,
                      styleSheet: MarkdownStyleSheet(
                        h1: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        p: const TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              /*_buildRoundedButton(
                icon: Icons.search,
                label:
                    isTeluguSelected
                        ? 'గూగుల్‌లో శోధించండి'
                        : 'Search on Google',
                onPressed: _launchInBrowser,
                backgroundColor: Colors.white,
                textColor: const Color(0xff1A5319),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
