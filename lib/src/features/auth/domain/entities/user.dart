class User {
  final String id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}
