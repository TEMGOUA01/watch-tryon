class ProfileAvatars {
  ProfileAvatars._();

  static const List<String> options = ['🦁', '🐺', '🦅', '🐉'];

  static String defaultForUid(String uid) {
    if (uid.isEmpty) return options.first;
    final index = uid.codeUnits.fold<int>(0, (sum, c) => sum + c) % options.length;
    return options[index];
  }

  static String sanitize(String? avatar) {
    if (avatar == null || !options.contains(avatar)) {
      return options.first;
    }
    return avatar;
  }
}
