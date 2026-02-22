import 'package:roadmaps/features/challenge/data/challenge_model.dart';
import 'package:roadmaps/core/constants/xp_rules.dart';

class ChallengeRepository {
  final List<ChallengeModel> _challenges = <ChallengeModel>[
    ChallengeModel(
      id: 1,
      learningUnitId: 7,
      title: 'اكتب كود',
      description:
          'اكتب برنامجا بسيطا ليقبل اسماء منتجات في مصفوفة مع سعر كل منتج، '
          'ثم يحسب التكلفة الاجمالية. ادخل 100 كحد اقصى من الاسماء kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk.',
      language: 'C++',
      minXp: XpRules.challengeUnlockMinXp,
      isActive: true,
      starterCode: '''
#include <iostream>
#include <iomanip>
using namespace std;

int main() {

  cout << ;
  return 0;
}
''',
      testCases: <ChallengeTestCaseModel>[
        ChallengeTestCaseModel(
          input: '3 apple 10 banana 15 orange 25',
          expectedOutput: '50.00',
        ),
        ChallengeTestCaseModel(
          input: '2 pen 5.5 book 12.5',
          expectedOutput: '18.00',
        ),
      ],
    ),
  ];

  final List<ChallengeAttemptModel> _attempts = <ChallengeAttemptModel>[];
  int _attemptIdSeed = 1;

  Future<ChallengeModel?> getChallengeByLearningUnitId(
    int learningUnitId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 350));
    try {
      return _challenges.firstWhere(
        (challenge) =>
            challenge.learningUnitId == learningUnitId && challenge.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<ChallengeRunResultModel> runCode({
    required int challengeId,
    required int userId,
    required String userCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedCode = userCode.trim();

    final bool forceFail = normalizedCode.contains('//mock_fail');
    final bool forceSuccess = normalizedCode.contains('//mock_success');
    final bool passed =
        forceSuccess ||
        (!forceFail &&
            normalizedCode.isNotEmpty &&
            normalizedCode.contains('main') &&
            normalizedCode.contains('cout'));

    final String executionOutput = passed
        ? 'تم التنفيذ بنجاح\nAll tests passed: 2/2\nOutput: 50.00'
        : 'Error in line 15\nهناك خطأ في الكود';

    _attempts.add(
      ChallengeAttemptModel(
        id: _attemptIdSeed++,
        challengeId: challengeId,
        userId: userId,
        userCode: userCode,
        executionOutput: executionOutput,
        passed: passed,
      ),
    );

    return ChallengeRunResultModel(
      passed: passed,
      executionOutput: executionOutput,
    );
  }
}
