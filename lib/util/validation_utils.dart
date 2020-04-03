
bool isValidPassword(String password) {
  return password.length >= 6;
}

bool isValidEmail(String email) {
  final _emailRegExpString = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
  return RegExp(_emailRegExpString, caseSensitive: false).hasMatch(email);
}

bool isValidFullName(String name) {
  return name.length >= 3;
}