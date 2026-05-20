class Validators {
  const Validators._();

  static bool isValidTechnicalPin(String value) {
    return RegExp(r'^[0-9]{4,}$').hasMatch(value);
  }
}

