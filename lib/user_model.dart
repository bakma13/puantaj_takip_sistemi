enum UserRole { regular, admin, superAdmin }

class User {
  final String id;
  final String username;
  final UserRole role; // Kullanıcının rolünü belirtir.

  User({
    required this.id,
    required this.username,
    this.role = UserRole.regular,
  });
}