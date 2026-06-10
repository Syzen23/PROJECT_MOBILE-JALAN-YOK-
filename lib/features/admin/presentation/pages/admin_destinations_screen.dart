import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/destination_model.dart';
import '../../../../core/widgets/cached_app_image.dart';

class AdminDestinationsScreen extends StatefulWidget {
  const AdminDestinationsScreen({super.key});

  @override
  State<AdminDestinationsScreen> createState() =>
      _AdminDestinationsScreenState();
}

class _AdminDestinationsScreenState extends State<AdminDestinationsScreen> {
  List<Destination> destinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    final data = await FirestoreService.instance.getAllDestinations();
    setState(() {
      destinations = data;
      isLoading = false;
    });
  }

  Future<void> _deleteDestination(String id) async {
    await FirestoreService.instance.deleteDestination(id);
    _loadDestinations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destinasi berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Destinasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final dest = destinations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: appImageProvider(dest.image),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  title: Text(
                    dest.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dest.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await context.push(
                            '/admin/destination-form',
                            extra: dest,
                          );
                          _loadDestinations();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDestination(dest.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/admin/destination-form');
          _loadDestinations();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
