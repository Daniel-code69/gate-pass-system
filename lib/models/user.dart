class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? fbUid;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.fbUid,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'role': role,
    if (fbUid != null) 'fbUid': fbUid,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as String,
    name: m['name'] as String,
    email: m['email'] as String,
    password: m['password'] as String,
    role: m['role'] as String,
    fbUid: m['fbUid'] as String?,
  );
}
