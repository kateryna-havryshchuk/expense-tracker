class CurrencyFormatter {
  static const Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'UAH': '₴',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
  };

  static String getSymbol(String currencyCode) {
    return symbols[currencyCode] ?? '\$';
  }

  static String format(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}