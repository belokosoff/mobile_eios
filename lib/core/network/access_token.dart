class AccessToken {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  AccessToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
    );
  }
}