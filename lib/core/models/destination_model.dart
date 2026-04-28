class Destination {
  final int? id;
  final String title;
  final String location;
  final String image;
  final double rating;
  final String visitors;
  final double tiket;
  final double jarak;
  final int waktu; // dalam jam

  Destination({
    this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.rating,
    required this.visitors,
    required this.tiket,
    required this.jarak,
    required this.waktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'image': image,
      'rating': rating,
      'visitors': visitors,
      'tiket': tiket,
      'jarak': jarak,
      'waktu': waktu,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      image: map['image'],
      rating: map['rating'],
      visitors: map['visitors'],
      tiket: map['tiket'],
      jarak: map['jarak'],
      waktu: map['waktu'],
    );
  }
}
