// All constants and data maps for the budget calculator

// === VEHICLE TYPE OPTIONS ===
const Map<String, List<Map<String, dynamic>>> vehicleTypes = {
  'Mobil': [
    {'label': 'City Car (Agya, Brio, Calya)', 'konsumsi': 15.0},
    {'label': 'MPV (Avanza, Xenia, Innova)', 'konsumsi': 12.0},
    {'label': 'SUV (Fortuner, Pajero, CR-V)', 'konsumsi': 9.0},
    {'label': 'Sedan (Civic, Vios, Camry)', 'konsumsi': 13.0},
  ],
  'Motor': [
    {'label': 'Matic (Beat, Vario, Nmax)', 'konsumsi': 45.0},
    {'label': 'Bebek (Supra, Revo)', 'konsumsi': 55.0},
    {'label': 'Sport (CBR, R15, Ninja)', 'konsumsi': 30.0},
  ],
};

// === FUEL TYPE OPTIONS ===
const List<Map<String, dynamic>> fuelTypes = [
  {'label': 'Pertalite', 'harga': 10000.0},
  {'label': 'Pertamax', 'harga': 13300.0},
  {'label': 'Pertamax Turbo', 'harga': 14400.0},
  {'label': 'Solar', 'harga': 6800.0},
  {'label': 'Dexlite', 'harga': 14550.0},
];

// === ACCOMMODATION TYPE OPTIONS ===
const List<Map<String, dynamic>> accommodationTypes = [
  {'label': 'Tidak Menginap', 'harga': 0.0},
  {'label': 'Homestay / Kos', 'harga': 150000.0},
  {'label': 'Guest House', 'harga': 250000.0},
  {'label': 'Hotel Bintang 1-2', 'harga': 350000.0},
  {'label': 'Hotel Bintang 3', 'harga': 500000.0},
  {'label': 'Hotel Bintang 4-5', 'harga': 1000000.0},
  {'label': 'Villa / Resort', 'harga': 800000.0},
];

// === MEAL FREQUENCY OPTIONS ===
const List<Map<String, dynamic>> mealFrequencies = [
  {'label': '1x Makan', 'value': 1},
  {'label': '2x Makan', 'value': 2},
  {'label': '3x Makan', 'value': 3},
];
