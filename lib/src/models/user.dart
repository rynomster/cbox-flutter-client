class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? profileUrl;
  final DateTime? lastActivity;
  final String? memberSince;
  final String? userStatus;
  final Map<String, dynamic>? extra;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.profileUrl,
    this.lastActivity,
    this.memberSince,
    this.userStatus,
    this.extra,
  });

  /// Factory constructor to parse a BuddyPress member response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['user_login'] as String? ?? '',
      email: json['user_email'] as String? ?? '',
      name: json['display_name'] as String? ?? json['user_nicename'] as String? ?? '',
      avatarUrl: json['avatar_urls']?['full'] as String? ??
          json['avatar_url'] as String?,
      profileUrl: json['profile_url'] as String?,
      lastActivity: json['last_activity'] != null
          ? DateTime.tryParse(json['last_activity'] as String)
          : null,
      memberSince: json['registered'] as String?,
      userStatus: json['status'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  /// Convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_login': username,
      'user_email': email,
      'display_name': name,
      'avatar_urls': {
        'full': avatarUrl,
      },
      'profile_url': profileUrl,
      'last_activity': lastActivity?.toIso8601String(),
      'registered': memberSince,
      'status': userStatus,
      'extra': extra,
    };
  }

  /// Create a copy of this User with modified fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? avatarUrl,
    String? profileUrl,
    DateTime? lastActivity,
    String? memberSince,
    String? userStatus,
    Map<String, dynamic>? extra,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profileUrl: profileUrl ?? this.profileUrl,
      lastActivity: lastActivity ?? this.lastActivity,
      memberSince: memberSince ?? this.memberSince,
      userStatus: userStatus ?? this.userStatus,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
