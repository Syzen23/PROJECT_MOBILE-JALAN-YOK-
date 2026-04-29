class User {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String role; // 'admin' or 'user'
  final String? phoneNumber;
  final int? age;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profileImageUrl;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.age,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
      'age': age,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return User(
      id: documentId ?? map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'user',
      phoneNumber: map['phone_number'],
      age: map['age'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
