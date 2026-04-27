import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // State variables
  String _selectedTransport = 'Mobil';
  bool _isTiketOtomatis = true;
  bool _isParkirOtomatis = true;

  // Controllers
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _bbmController = TextEditingController();
  final TextEditingController _tiketController = TextEditingController();
  final TextEditingController _parkirController = TextEditingController();
  final TextEditingController _makanController = TextEditingController();
  final TextEditingController _penginapanController = TextEditingController();
  
  // Destination Database
  final List<Map<String, dynamic>> destinations = [
    {
      'title': 'Pantai Marina',
      'location': 'Kalianda, Lampung',
      'tiket': 20000,
      'jarak': 120.0,
      'waktu': 3,
    },
    {
      'title': 'Gunung Bromo',
      'location': 'Jawa Timur',
      'tiket': 35000,
      'jarak': 850.0,
      'waktu': 12,
    },
    {
      'title': 'Tari Kecak',
      'location': 'Bali',
      'tiket': 150000,
      'jarak': 1200.0,
      'waktu': 24,
    },
    {
      'title': 'Nusa Penida',
      'location': 'Bali',
      'tiket': 25000,
      'jarak': 1250.0,
      'waktu': 25,
    },
    {
      'title': 'Toraja',
      'location': 'Sulawesi Selatan',
      'tiket': 50000,
      'jarak': 2000.0,
      'waktu': 48,
    },
  ];

  late Map<String, dynamic> _selectedDestination;

  // Constants
  final double hargaBbmPerLiter = 10000.0; // Asumsi harga BBM

  // Results
  double _biayaBBM = 0;
  double _biayaTiket = 0;
  double _biayaParkir = 0;
  double _biayaMakan = 0;
  double _biayaPenginapan = 0;
  double _totalBiaya = 0;

  @override
  void initState() {
    super.initState();
    _selectedDestination = destinations[0]; // Default to Pantai Marina
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _bbmController.dispose();
    _tiketController.dispose();
    _parkirController.dispose();
    _makanController.dispose();
    _penginapanController.dispose();
    super.dispose();
  }

  void _hitungBudget() {
    double jarak = _selectedDestination['jarak'];

    // 1. BBM
    double konsumsiBbm = double.tryParse(_bbmController.text) ?? 0;
    if (konsumsiBbm > 0) {
      _biayaBBM = (jarak / konsumsiBbm) * hargaBbmPerLiter;
    } else {
      _biayaBBM = 0;
    }

    // 2. Tiket
    if (_isTiketOtomatis) {
      _biayaTiket = _selectedDestination['tiket'].toDouble();
    } else {
      _biayaTiket = double.tryParse(_tiketController.text) ?? 0;
    }

    // 3. Parkir
    if (_isParkirOtomatis) {
      _biayaParkir = _selectedTransport == 'Motor' ? 5000 : 10000;
    } else {
      _biayaParkir = double.tryParse(_parkirController.text) ?? 0;
    }

    // 4. Makan & Penginapan
    _biayaMakan = double.tryParse(_makanController.text) ?? 0;
    _biayaPenginapan = double.tryParse(_penginapanController.text) ?? 0;

    // Total
    _totalBiaya = _biayaBBM + _biayaTiket + _biayaParkir + _biayaMakan + _biayaPenginapan;

    setState(() {});
    DefaultTabController.of(context).animateTo(1);
  }

  String _formatCurrency(double amount) {
    String res = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = res.length - 1; i >= 0; i--) {
      result = res[i] + result;
      count++;
      if (count % 3 == 0 && i > 0) {
        result = '.$result';
      }
    }
    return result; // Format "123.456"
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Container(
                color: Colors.white, // Putih tanpa gradien biru
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300, width: 1.0), // Border halus karena background putih
                    ),
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [_buildHitungBudgetTab(), _buildHasilTab()],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background Image
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xFF007AFF),
            image: DecorationImage(
              image: AssetImage('assets/images/travel.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Route Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Dots and line indicator
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF007AFF,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 24,
                            color: Colors.grey.shade300,
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Locations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Anda',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(height: 16),
                            Autocomplete<Map<String, dynamic>>(
                              initialValue: TextEditingValue(text: _selectedDestination['title']),
                              displayStringForOption: (option) => option['title'],
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return destinations;
                                }
                                return destinations.where((option) {
                                  return option['title'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (Map<String, dynamic> selection) {
                                setState(() {
                                  _selectedDestination = selection;
                                });
                              },
                              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                return TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: 'Cari Tujuan...',
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: const TabBar(
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.orange,
        indicatorWeight: 3,
        tabs: [Tab(text: 'Hitung Budget'), Tab(text: 'Hasil')],
      ),
    );
  }

  Widget _buildHitungBudgetTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  'Budget',
                  'Contoh: 2000000',
                  controller: _budgetController,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTransportDropdown(),
                const SizedBox(height: 16),
                _buildInputField(
                  'Konsumsi BBM',
                  'Contoh: 40 km/l',
                  controller: _bbmController,
                  isNumber: true,
                ),
                const SizedBox(height: 24),
                _buildBiayaTambahanSection(),
              ],
            ),
          ),
        ),
        // Hitung Button inside the white card
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _hitungBudget,
              icon: const Icon(Icons.search, size: 18),
              label: const Text(
                'Hitung Budget',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transportasi',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTransport,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items:
                  ['Mobil', 'Motor', 'Bus', 'Kereta'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTransport = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBiayaTambahanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biaya Tambahan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildOtomatisField(
            'Tiket masuk',
            'Contoh: 10000',
            _tiketController,
            _isTiketOtomatis,
            (val) => setState(() => _isTiketOtomatis = val),
          ),
          const SizedBox(height: 16),
          _buildOtomatisField(
            'Parkir',
            'Contoh: 5000',
            _parkirController,
            _isParkirOtomatis,
            (val) => setState(() => _isParkirOtomatis = val),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Makan',
            'Contoh: 150000',
            controller: _makanController,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Penginapan(Opsional)',
            'Contoh: 200000/tidak usah diisi',
            controller: _penginapanController,
            isNumber: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              contentPadding: const EdgeInsets.only(bottom: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtomatisField(
    String label,
    String hint,
    TextEditingController controller,
    bool isOtomatis,
    Function(bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  enabled: !isOtomatis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOtomatis ? Colors.grey : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.only(bottom: 12),
                  ),
                ),
              ),
              PopupMenuButton<bool>(
                initialValue: isOtomatis,
                onSelected: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: true,
                    child: Text('Otomatis', style: TextStyle(fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: false,
                    child: Text('Manual', style: TextStyle(fontSize: 12)),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOtomatis ? 'Otomatis' : 'Manual',
                        style: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF007AFF),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHasilTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Estimasi Perjalanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultBox('Jarak', '${_selectedDestination['jarak'].toInt()} km'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildResultBox('Waktu', '${_selectedDestination['waktu']} Jam')),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Biaya',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultBox('BBM', _formatCurrency(_biayaBBM)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildResultBox(
                        'Tiket masuk',
                        _formatCurrency(_biayaTiket),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultBox(
                        'Parkir',
                        _formatCurrency(_biayaParkir),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildResultBox(
                        'Makan',
                        _formatCurrency(_biayaMakan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultBox(
                        'Penginapan',
                        _formatCurrency(_biayaPenginapan),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: const SizedBox()), // Empty space to align
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResultBox(
                  '',
                  _formatCurrency(_totalBiaya),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        // Hitung Button inside the white card
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                DefaultTabController.of(context).animateTo(0);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Budget', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBox(String title, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: isTotal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          width: isTotal ? 160 : double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
          ),
          child: Text(
            value,
            textAlign: isTotal ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
