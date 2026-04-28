import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/destination_model.dart';

class DestinationFormScreen extends StatefulWidget {
  final Destination? destination;

  const DestinationFormScreen({super.key, this.destination});

  @override
  State<DestinationFormScreen> createState() => _DestinationFormScreenState();
}

class _DestinationFormScreenState extends State<DestinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _ratingCtrl;
  late TextEditingController _visitorsCtrl;
  late TextEditingController _tiketCtrl;
  late TextEditingController _waktuCtrl;

  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dest = widget.destination;
    _titleCtrl = TextEditingController(text: dest?.title ?? '');
    _locationCtrl = TextEditingController(text: dest?.location ?? '');
    _imagePath = dest?.image;
    _ratingCtrl = TextEditingController(text: dest?.rating.toString() ?? '4.5');
    _visitorsCtrl = TextEditingController(text: dest?.visitors ?? '1K+ Pengunjung');
    _tiketCtrl = TextEditingController(text: dest?.tiket.toString() ?? '10000');
    _waktuCtrl = TextEditingController(text: dest?.waktu.toString() ?? '1');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _ratingCtrl.dispose();
    _visitorsCtrl.dispose();
    _tiketCtrl.dispose();
    _waktuCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih gambar terlebih dahulu')));
      return;
    }

    setState(() => _isLoading = true);

    final dest = Destination(
      id: widget.destination?.id,
      title: _titleCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      image: _imagePath!,
      rating: double.tryParse(_ratingCtrl.text) ?? 4.0,
      visitors: _visitorsCtrl.text.trim(),
      tiket: double.tryParse(_tiketCtrl.text) ?? 0,
      waktu: int.tryParse(_waktuCtrl.text) ?? 1,
    );

    if (dest.id == null) {
      await FirestoreService.instance.create(dest);
    } else {
      await FirestoreService.instance.updateDestination(dest);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination == null ? 'Tambah Destinasi' : 'Edit Destinasi'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _imagePath!.startsWith('assets/')
                              ? Image.asset(_imagePath!, fit: BoxFit.cover)
                              : Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Pilih Foto', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(_titleCtrl, 'Nama Destinasi'),
              _buildField(_locationCtrl, 'Lokasi'),
              _buildField(_ratingCtrl, 'Rating', isNumber: true),
              _buildField(_visitorsCtrl, 'Pengunjung (contoh: 1K+ Pengunjung)'),
              _buildField(_tiketCtrl, 'Harga Tiket (Rp)', isNumber: true),
              _buildField(_waktuCtrl, 'Waktu (Jam)', isNumber: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDestination,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Destinasi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
      ),
    );
  }
}
