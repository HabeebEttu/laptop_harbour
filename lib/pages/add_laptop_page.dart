
import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';

class AddLaptopPage extends StatefulWidget {
  const AddLaptopPage({super.key});

  @override
  State<AddLaptopPage> createState() => _AddLaptopPageState();
}

class _AddLaptopPageState extends State<AddLaptopPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _tagsController = TextEditingController();
  final _processorController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _displayController = TextEditingController();
  final _graphicsCardController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _discountExpiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Laptop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _oldPriceController,
                  decoration: const InputDecoration(labelText: 'Old Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an old price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rating';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one tag';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _processorController,
                  decoration: const InputDecoration(labelText: 'Processor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a processor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ramController,
                  decoration: const InputDecoration(labelText: 'RAM'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter RAM details';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _storageController,
                  decoration: const InputDecoration(labelText: 'Storage'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter storage details';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _displayController,
                  decoration: const InputDecoration(labelText: 'Display'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter display details';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _graphicsCardController,
                  decoration: const InputDecoration(labelText: 'Graphics Card'),
                ),
                TextFormField(
                  controller: _discountValueController,
                  decoration: const InputDecoration(labelText: 'Discount Value'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _discountExpiryDateController,
                  decoration: const InputDecoration(labelText: 'Discount Expiry Date (YYYY-MM-DD)'),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final specs = Specs(
                        processor: _processorController.text,
                        ram: _ramController.text,
                        storage: _storageController.text,
                        display: _displayController.text,
                        graphicsCard: _graphicsCardController.text,
                      );
                      final discount = _discountValueController.text.isNotEmpty
                          ? Discount(
                              value: double.parse(_discountValueController.text),
                              expiryDate: DateTime.parse(_discountExpiryDateController.text),
                            )
                          : null;
                      final laptop = Laptop(
                        title: _titleController.text,
                        price: double.parse(_priceController.text),
                        oldPrice: double.parse(_oldPriceController.text),
                        image: _imageUrlController.text,
                        rating: double.parse(_ratingController.text),
                        reviews: [],
                        tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
                        specs: specs,
                        discount: discount,
                      );
                      Provider.of<LaptopProvider>(context, listen: false)
                          .addLaptop(laptop);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add Laptop'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
