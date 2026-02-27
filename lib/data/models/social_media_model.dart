class SocialMediaUser {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePicture;
  final String? bio;
  final DateTime? createdAt;

  SocialMediaUser({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePicture,
    this.bio,
    this.createdAt,
  });

  factory SocialMediaUser.fromJson(Map<String, dynamic> json) {
    return SocialMediaUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final SocialMediaUser? user;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'] ?? json['data']?['access_token'],
      refreshToken: json['refresh_token'] ?? json['data']?['refresh_token'],
      user: json['user'] != null 
          ? SocialMediaUser.fromJson(json['user'])
          : json['data']?['user'] != null
              ? SocialMediaUser.fromJson(json['data']['user'])
              : null,
    );
  }
}
