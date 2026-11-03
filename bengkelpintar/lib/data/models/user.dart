class User {
  const User({
    required this.id,
    required this.nama,
    required this.peran,
    this.username,
    this.aktif,
  });

  final int id;
  final String nama;
  final String peran;
  final String? username;
  final bool? aktif;
  User copyWith({String? nama, String? peran, String? username, bool? aktif}) =>
      User(
        id: id,
        nama: nama ?? this.nama,
        peran: peran ?? this.peran,
        username: username ?? this.username,
        aktif: aktif ?? this.aktif,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num).toInt(),
    nama: json['nama'] as String,
    peran: json['peran'] as String,
    username: json['username'] as String?,
    aktif: json['aktif'] as bool?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'peran': peran,
    'username': username,
    'aktif': aktif,
  };
}
