import 'package:roadmaps/features/checkpoints/data/checkpoint_model.dart';

class CheckpointRepository {
  Future<CheckpointModel> getCheckpoint({
    required String learningPathId,
    required String checkpointId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));
    return _buildFakeCheckpoint(
      learningPathId: learningPathId,
      checkpointId: checkpointId,
    );
  }

  CheckpointModel _buildFakeCheckpoint({
    required String learningPathId,
    required String checkpointId,
  }) {
    final String checkpointKey = '${learningPathId}_$checkpointId';

    return CheckpointModel(
      id: checkpointKey,
      title: 'C++',
      subtitle: 'اكمل الاختبار للحصول على نقاط خبرة',
      questions: const [
        QuestionModel(
          id: 'q1',
          text: 'ما هو الشكل الصحيح لدالة تقبل متغيرين من نوع int وتعيد void؟',
          correctOptionId: 'q1_o1',
          options: [
            OptionModel(id: 'q1_o1', text: 'void fun(int x, int y)'),
            OptionModel(id: 'q1_o2', text: 'void fun(x, y)'),
          ],
        ),
        QuestionModel(
          id: 'q2',
          text: 'ما الحجم الشائع لنوع البيانات int في أغلب الأنظمة الحديثة؟',
          correctOptionId: 'q2_o2',
          options: [
            OptionModel(id: 'q2_o1', text: '8 bit'),
            OptionModel(id: 'q2_o2', text: '32 bit'),
            OptionModel(id: 'q2_o3', text: '128 bit'),
          ],
        ),
        QuestionModel(
          id: 'q3',
          text: 'أي جملة تطبع النص Product في C++ بشكل صحيح؟',
          correctOptionId: 'q3_o3',
          options: [
            OptionModel(id: 'q3_o1', text: "print('Product');"),
            OptionModel(id: 'q3_o2', text: 'echo Product;'),
            OptionModel(id: 'q3_o3', text: 'cout << "Product";'),
            OptionModel(id: 'q3_o4', text: 'Console.WriteLine("Product");'),
          ],
        ),
        QuestionModel(
          id: 'q4',
          text: 'أي تعريف صحيح لدالة لا تستقبل معاملات وتعيد int؟',
          correctOptionId: 'q4_o2',
          options: [
            OptionModel(id: 'q4_o1', text: 'void run()'),
            OptionModel(id: 'q4_o2', text: 'int run()'),
          ],
        ),
        QuestionModel(
          id: 'q5',
          text: 'ما الكلمة الصحيحة لقراءة قيمة من المستخدم في C++؟',
          correctOptionId: 'q5_o1',
          options: [
            OptionModel(id: 'q5_o1', text: 'cin'),
            OptionModel(id: 'q5_o2', text: 'scan'),
            OptionModel(id: 'q5_o3', text: 'readLine'),
          ],
        ),
      ],
    );
  }
}
