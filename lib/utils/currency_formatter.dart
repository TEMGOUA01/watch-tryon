String formatCfa(int amount) {
  final raw = amount.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = raw.length - 1; i >= 0; i--) {
    buffer.write(raw[i]);
    count++;
    if (count % 3 == 0 && i != 0) {
      buffer.write(' ');
    }
  }
  return '${buffer.toString().split('').reversed.join()} F CFA';
}
