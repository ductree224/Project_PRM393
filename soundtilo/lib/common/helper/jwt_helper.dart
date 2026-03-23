import 'dart:convert';

class JwtHelper {
  const JwtHelper._();

  static String? extractRole(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(payload);
      if (map is! Map<String, dynamic>) {
        return null;
      }

      final role =
          map['role'] ??
          map['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      if (role is String && role.trim().isNotEmpty) {
        return role.trim().toLowerCase();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool isAdmin(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }
    return extractRole(token) == 'admin';
  }
}
