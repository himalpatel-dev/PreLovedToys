import 'dart:convert';

/// Turns an error thrown by ApiService into a sentence a user can read.
///
/// ApiService throws `Exception('Error: <status> <response body>')` for server errors
/// and `Exception('Network Error: ...')` when the server can't be reached. The backend
/// puts a readable reason in the body's `message` field, so that is shown when present.
String friendlyError(Object error) {
  final text = error.toString();

  final match = RegExp(r'Error: (\d{3}) (.*)$', dotAll: true).firstMatch(text);
  if (match != null) {
    try {
      final body = jsonDecode(match.group(2)!);
      if (body is Map && body['message'] is String && (body['message'] as String).trim().isNotEmpty) {
        return body['message'] as String;
      }
    } catch (_) {
      // Body wasn't JSON; fall through to the generic message.
    }
    return 'Something went wrong (error ${match.group(1)}). Please try again.';
  }

  if (text.contains('Network Error') ||
      text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection refused')) {
    return "Can't reach PreLoved Toys right now. Check your internet connection and try again.";
  }

  return 'Something went wrong. Please try again.';
}

/// True when the server refused the request because the account is banned.
bool isAccountBlocked(Object error) => error.toString().contains('ACCOUNT_BLOCKED');
