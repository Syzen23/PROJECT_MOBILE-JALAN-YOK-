class Destination {
  final int? id;
  final String title;
  final String location;
  final String image;
  final double rating;
  final String visitors;
  final double tiket;
  final int waktu; // dalam jam

  Destination({
    this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.rating,
    required this.visitors,
    required this.tiket,
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
      'waktu': waktu,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      image: map['image'],
      rating: map['rating'] as double,
      visitors: map['visitors'] as String,
      tiket: map['tiket'] as double,
      waktu: map['waktu'] as int,
    );
  }
}
