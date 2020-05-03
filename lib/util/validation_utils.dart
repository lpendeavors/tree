
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

bool isPhoneNumberValid(String phone) {
  var phoneNumber = phone
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("-", "")
      .replaceAll(" ", "");
  return phoneNumber.length == 10;
}

bool isValidVerificationCode(String verification) {
  return verification.length == 6;
}

bool isValidVerificationId(String id) {
  return id.length > 0;
}