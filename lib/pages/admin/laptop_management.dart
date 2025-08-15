import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/laptop_service.dart';

class LaptopManagementPage extends StatefulWidget {
  const LaptopManagementPage({super.key});

  @override
  State<LaptopManagementPage> createState() => _LaptopManagementPageState();
}

class _LaptopManagementPageState extends State<LaptopManagementPage> {
  final LaptopService _laptopService = LaptopService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laptop Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add laptop page
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Laptop>>(
        stream: _laptopService.getLaptops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No laptops found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final laptop = snapshot.data![index];
              return ListTile(
                leading: Image.network(
                  laptop.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(laptop.title),
                subtitle: Text('₦${laptop.price}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit laptop page
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final bool? shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Laptop'),
                            content: Text(
                                'Are you sure you want to delete ${laptop.title}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (shouldDelete == true) {
                          await _laptopService.deleteLaptop(laptop.id!);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to laptop details
                },
              );
            },
          );
        },
      ),
    );
  }
}
