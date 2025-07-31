class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final DateTime? createdAt;
  
  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}