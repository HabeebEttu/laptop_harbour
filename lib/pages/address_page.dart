import 'package:flutter/material.dart';

class Address {
  final String type;
  final String line1;
  final String city;
  final String state;
  final String zip;

  Address(this.type, this.line1, this.city, this.state, this.zip);
}

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final List<Address> _addresses = [
    Address('Home', '123 Main Street', 'Anytown', 'CA', '90210'),
    Address('Work', '456 Oak Avenue', 'Anytown', 'CA', '90210'),
  ];

  int _selectedAddressIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add address page
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return _buildAddressCard(
            context,
            address,
            isSelected: _selectedAddressIndex == index,
            onTap: () {
              setState(() {
                _selectedAddressIndex = index;
              });
              Navigator.of(context).pop(address);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    Address address, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(address.type,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${address.line1}, ${address.city}, ${address.state} ${address.zip}'),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: onTap,
      ),
    );
  }
}
