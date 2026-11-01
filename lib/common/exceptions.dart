class NoCredsException implements Exception {
  final String message;
  NoCredsException([this.message = "no_creds"]);

  @override
  String toString() => "NoCredsException: $message";
}

class NoScrollException implements Exception {
  final String message;
  final String type;
  NoScrollException(this.type, [this.message = "no_scroll"]);

  @override
  String toString() => "NoCredsException: $message";
}
