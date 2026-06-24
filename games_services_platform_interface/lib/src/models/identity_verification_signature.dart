class IdentityVerificationSignature {
  /// URL to the public key for verifying the signature
  final String publicKeyURL;

  /// Base64 encoded signature
  final String signature;

  /// Base64 encoded salt
  final String salt;

  /// Timestamp value
  final int timestamp;

  const IdentityVerificationSignature({
    required this.publicKeyURL,
    required this.signature,
    required this.salt,
    required this.timestamp,
  });

  factory IdentityVerificationSignature.fromJson(Map<String, dynamic> json) {
    return IdentityVerificationSignature(
      publicKeyURL: json["publicKeyURL"] as String,
      signature: json["signature"] as String,
      salt: json["salt"] as String,
      timestamp: json["timestamp"] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "publicKeyURL": publicKeyURL,
      "signature": signature,
      "salt": salt,
      "timestamp": timestamp,
    };
  }
}
