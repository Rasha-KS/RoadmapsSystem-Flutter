import 'package:roadmaps/core/api/api_exceptions.dart';

class EnrollmentReset {
  static Future<bool> perform({
    required Future<Map<String, dynamic>> Function() deleteEnrollment,
    required Future<Map<String, dynamic>> Function() enrollAgain,
    required void Function(Map<String, dynamic> response) handleDeleteResponse,
    required void Function(Map<String, dynamic> response) handleEnrollResponse,
  }) async {
    try {
      final deleteResponse = await deleteEnrollment();
      handleDeleteResponse(deleteResponse);

      final enrollResponse = await enrollAgain();
      handleEnrollResponse(enrollResponse);
      return true;
    } on ApiException {
      return false;
    }
  }
}
