
bool isValidPassword(String password) {
  return password.length >= 6;
}

bool isValidEmail(String email) {
  final _emailRegExpString = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
  return RegExp(_emailRegExpString, caseSensitive: false).hasMatch(email);
}

bool isBusinessEmail(String email) {
  if (email.contains("aol") ||
      email.contains("gmail") ||
      email.contains("yahoo") ||
      email.contains("hotmail")) return false;
  return true;
}

bool isValidName(String name) {
  return name.length >= 2;
}

bool isPhoneNumberValid(String phone) {
  var phoneNo = phone
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("-", "")
      .replaceAll(" ", "");
  return phoneNo.length == 10;
}

bool isValidVerificationCode(String verification) {
  return verification.length == 6;
}

bool isValidVerificationId(String id) {
  return id.length > 0;
}