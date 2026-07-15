import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String? _photoUrl;
  String? _category;
  bool _isAnalyzing = false;
  final _addressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  
  final List<String> _validCategories = ['PET Plastic', 'Cardboard', 'Metal', 'Cooking Oil'];

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _isAnalyzing = true);
      
      try {
        final uploadRes = await ApiService.upload(ApiConstants.upload, pickedFile.path);
        final uploadData = jsonDecode(uploadRes.body);
        
        if (uploadRes.statusCode == 200 && uploadData['success'] == true) {
          final imageUrl = uploadData['data']['url'];
          setState(() => _photoUrl = imageUrl);

          final analyzeRes = await ApiService.post(ApiConstants.analyzeImage, {
            'photo_url': imageUrl,
          });
          
          final analyzeData = jsonDecode(analyzeRes.body);
          if (analyzeRes.statusCode == 200 && analyzeData['success'] == true) {
            setState(() {
              _category = analyzeData['data']['category'];
            });
          } else {
             // Fallback if AI fails (set default)
             setState(() {
              _category = _validCategories.first;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Analysis unavailable. Please select category manually.')));
            }
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed. Please try again.')));
      } finally {
        if (mounted) setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _submitOrder() async {
    if (_photoUrl == null || _category == null || _addressCtrl.text.trim().isEmpty || _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload a photo')),
      );
      return;
    }

    final double? weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid estimated weight')),
      );
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable GPS to fetch location.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission required.')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    } 

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locating & processing order...')));
    
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;
      final success = await context.read<UserProvider>().createOrder(
        photoUrl: _photoUrl!,
        category: _category!,
        weightKg: weight,
        lat: position.latitude,
        lng: position.longitude,
        address: _addressCtrl.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order placed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
        context.pop();
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Recycle Waste', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Upload Photo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isAnalyzing ? null : _pickAndUploadImage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                      ],
                      image: _photoUrl != null
                          ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _isAnalyzing
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text('AI is analyzing your waste...', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500))
                            ],
                          )
                        : _photoUrl == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                                    child: Icon(Icons.document_scanner_rounded, size: 48, color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Tap to scan & upload', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                ],
                              )
                            : null,
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),
                
                if (_category != null) ...[
                  Text('Waste Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)).animate().fade(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                      ]
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.category_rounded, color: Colors.green),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _validCategories.contains(_category) ? _category : _validCategories.first,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: _validCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                                onChanged: (val) {
                                  setState(() => _category = val);
                                },
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.scale_rounded, color: Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _weightCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Estimated Weight (kg)',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                  
                  const SizedBox(height: 24),
                  Text('Pickup Location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)).animate().fade(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))
                      ]
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on_rounded, color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Full Address',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 2,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isAnalyzing || userProv.isLoading) ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      child: userProv.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirm & Fetch GPS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fade(delay: 200.ms).scale()
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
