import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/services/supabase_storage_service.dart';
import 'package:provider/provider.dart';

class AddLaptopPage extends StatefulWidget {
  const AddLaptopPage({super.key});

  @override
  State<AddLaptopPage> createState() => _AddLaptopPageState();
}

class _AddLaptopPageState extends State<AddLaptopPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late SupabaseStorageService _storageService;

  // Controllers
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _tagsController = TextEditingController();
  final _processorController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _displayController = TextEditingController();
  final _graphicsCardController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _discountExpiryDateController = TextEditingController();
  final _stockAmountController = TextEditingController();

  // State variables
  XFile? _image;
  Uint8List? _imageBytes;
  Category? _selectedCategory;
  bool _isLoading = false;
  bool _hasDiscount = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _storageService = SupabaseStorageService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _tagsController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _displayController.dispose();
    _graphicsCardController.dispose();
    _discountValueController.dispose();
    _discountExpiryDateController.dispose();
    _stockAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      _discountExpiryDateController.text = date.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Add New Laptop'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveLaptop,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basic Info', icon: Icon(Icons.info_outline)),
            Tab(text: 'Specs', icon: Icon(Icons.memory)),
            Tab(text: 'Image', icon: Icon(Icons.photo_camera)),
            Tab(text: 'Pricing', icon: Icon(Icons.attach_money)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildSpecsTab(),
            _buildImageTab(),
            _buildPricingTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Product Information',
            icon: Icons.laptop_mac,
            children: [
              _buildTextFormField(
                controller: _titleController,
                label: 'Product Title',
                hint: 'Enter laptop title',
                icon: Icons.title,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _brandController,
                label: 'Brand',
                hint: 'Enter brand name',
                icon: Icons.business,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a brand' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter laptop description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _ratingController,
                label: 'Rating (1-5)',
                hint: '4.5',
                icon: Icons.star_outline,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter a rating';
                  final rating = double.tryParse(value!);
                  if (rating == null || rating < 1 || rating > 5) {
                    return 'Rating must be between 1 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _tagsController,
                label: 'Tags',
                hint: 'gaming, professional, ultrabook',
                icon: Icons.label_outline,
                maxLines: 2,
                validator: (value) => value?.isEmpty == true
                    ? 'Please enter at least one tag'
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Category',
            icon: Icons.category_outlined,
            children: [_buildCategoryDropdown()],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Hardware Specifications',
            icon: Icons.memory,
            children: [
              _buildTextFormField(
                controller: _processorController,
                label: 'Processor',
                hint: 'Intel Core i7-12700H',
                icon: Icons.developer_board,
                validator: (value) => value?.isEmpty == true
                    ? 'Please enter processor details'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _ramController,
                      label: 'RAM',
                      hint: '16GB DDR4',
                      icon: Icons.memory,
                      validator: (value) => value?.isEmpty == true
                          ? 'Please enter RAM details'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _storageController,
                      label: 'Storage',
                      hint: '512GB SSD',
                      icon: Icons.storage,
                      validator: (value) => value?.isEmpty == true
                          ? 'Please enter storage details'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _displayController,
                label: 'Display',
                hint: '15.6" FHD IPS 144Hz',
                icon: Icons.monitor,
                validator: (value) => value?.isEmpty == true
                    ? 'Please enter display details'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _graphicsCardController,
                label: 'Graphics Card',
                hint: 'NVIDIA RTX 3060',
                icon: Icons.videogame_asset,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Product Image',
            icon: Icons.photo_camera,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select an image',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_imageBytes != null) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _image = null;
                          _imageBytes = null;
                        });
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove image',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Pricing Information',
            icon: Icons.attach_money,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _priceController,
                      label: 'Price ()',
                      hint: '1299.99',
                      icon: Icons.monetization_on_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Please enter a price';
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _stockAmountController,
                      label: 'Stock Amount',
                      hint: '10',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Please enter stock amount';
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Discount (Optional)',
            icon: Icons.local_offer_outlined,
            children: [
              SwitchListTile(
                title: const Text('Enable Discount'),
                subtitle: Text(
                  _hasDiscount ? 'Discount is enabled' : 'No discount applied',
                ),
                value: _hasDiscount,
                onChanged: (value) {
                  setState(() {
                    _hasDiscount = value;
                    if (!value) {
                      _discountValueController.clear();
                      _discountExpiryDateController.clear();
                    }
                  });
                },
              ),
              if (_hasDiscount) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _discountValueController,
                        label: 'Discount (%)',
                        hint: '15',
                        icon: Icons.percent,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (_hasDiscount && value?.isEmpty == true) {
                            return 'Please enter discount value';
                          }
                          if (value?.isNotEmpty == true) {
                            final discount = double.tryParse(value!);
                            if (discount == null ||
                                discount < 0 ||
                                discount > 100) {
                              return 'Enter valid discount (0-100)';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: _buildTextFormField(
                            controller: _discountExpiryDateController,
                            label: 'Expiry Date',
                            hint: 'Select date',
                            icon: Icons.calendar_today,
                            validator: (value) {
                              if (_hasDiscount && value?.isEmpty == true) {
                                return 'Please select expiry date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: StreamBuilder<List<Category>>(
        stream: context.read<CategoryProvider>().getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading categories...'),
              ],
            );
          }

          if (snapshot.hasError) {
            return Row(
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Text('Error: ${snapshot.error}'),
              ],
            );
          }

          final categories = snapshot.data ?? [];

          return DropdownButton<Category>(
            value: _selectedCategory,
            hint: const Row(
              children: [
                Icon(Icons.category_outlined, size: 20),
                SizedBox(width: 8),
                Text('Select Category'),
              ],
            ),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: categories
                .map(
                  (category) => DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveLaptop,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Laptop'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLaptop() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a product image'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(2); // Switch to image tab
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(0); // Switch to basic info tab
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Supabase Storage
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

      // Create specs object
      final specs = Specs(
        processor: _processorController.text.trim(),
        ram: _ramController.text.trim(),
        storage: _storageController.text.trim(),
        display: _displayController.text.trim(),
        graphicsCard: _graphicsCardController.text.trim().isNotEmpty
            ? _graphicsCardController.text.trim()
            : null,
      );

      // Create discount object if applicable
      Discount? discount;
      if (_hasDiscount && _discountValueController.text.isNotEmpty) {
        discount = Discount(
          value: double.parse(_discountValueController.text),
          expiryDate: DateTime.parse(_discountExpiryDateController.text),
        );
      }

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create laptop object
      final laptop = Laptop(
        id: '', // Will be generated by Firestore
        title: _titleController.text.trim(),
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        image: imageUrl,
        rating: double.parse(_ratingController.text),
        tags: tags,
        specs: specs,
        discount: discount,
        categoryId: _selectedCategory!.id,
        stockAmount: int.parse(_stockAmountController.text.trim()),
      );

      // Add laptop using provider
      final laptopProvider = context.read<LaptopProvider>();
      await laptopProvider.addLaptop(laptop);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Laptop added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to add laptop: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null || _imageBytes == null) return null;

    try {
     
      final fileName = 'laptop_${DateTime.now().millisecondsSinceEpoch}.jpg';

      
      final imageUrl = await _storageService.uploadImage(
        imageBytes: _imageBytes!,
        fileName: fileName,
        folder: 'laptops',
      );
      
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }
}
