/// In-memory authentication service storing current JWT token and logged-in user data.
class AuthService {
  static String? token;
  static Map<String, dynamic>? userData;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void setAuthData(String userToken, Map<String, dynamic> user) {
    token = userToken;
    userData = user;
  }

  static void clearAuth() {
    token = null;
    userData = null;
  }
}
