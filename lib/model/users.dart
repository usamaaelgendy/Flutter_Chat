class Users {
  String email;
  String userId;
  String userName;
  String profilePic;
  bool isOnline;
  String fcmToken;

  Users(
      {this.email,
      this.userId,
      this.userName,
      this.profilePic,
      this.isOnline,
      this.fcmToken});

  Users.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) {
      return;
    }
    email = map['email'];
    userId = map['userId'];
    profilePic = map['profilePic'];
    userName = map['userName'];
    fcmToken = map['fcmToken'];
    isOnline = map['isOnline'] ?? false;
  }

  toJson() {
    return {
      "email": email,
      'userId': userId,
      'profilePic': profilePic,
      'userName': userName,
      'isOnline': isOnline ?? false,
      'fcmToken': fcmToken,
    };
  }

  Users copyWith({
    String email,
    String userId,
    String profilePic,
    String key,
    String createdAt,
    String userName,
    String fcmToken,
  }) {
    return Users(
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      profilePic: profilePic ?? this.profilePic,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
