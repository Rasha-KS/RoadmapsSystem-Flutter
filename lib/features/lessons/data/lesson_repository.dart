import 'package:roadmaps/features/lessons/data/lesson_model.dart';

class LessonRepository {
  Future<LessonModel> getLesson(String learningUnitId) async {
    await Future.delayed(const Duration(milliseconds: 650));
    return _buildLesson(learningUnitId);
  }

  LessonModel _buildLesson(String learningUnitId) {
    final int unitNumber = int.tryParse(learningUnitId) ?? 1;
    final String prefix = 'unit_$unitNumber';

    String topicAt(int offset) => _topics[(unitNumber - 1 + offset) % _topics.length];

    return LessonModel(
      id: learningUnitId,
      title: 'أساسيات البرمجة',
      subLessons: [
        SubLessonModel(
          id: '${prefix}_sub_1',
          title: topicAt(0),
          introductionTitle: 'المقدمة',
          introductionDescription:
              'في هذا الجزء نتعرف على ${topicAt(0)} وكيفية استخدامها في تطبيقات C++ العملية.',
          resources: [
            const ResourceModel(
              id: 'resource_youtube_1',
              type: 'youtube',
              title: 'قناة أحمد عمر',
              link: 'https://www.youtube.com/watch?v=0W6V7xYQxVw',
            ),
            const ResourceModel(
              id: 'resource_book_1',
              type: 'book',
              title: 'أساسيات البرمجة بلغة C++',
              link:
                  'https://www.pearson.com/en-us/subject-catalog/p/c-how-to-program/P200000003006',
            ),
          ],
        ),
        SubLessonModel(
          id: '${prefix}_sub_2',
          title: topicAt(1),
          introductionTitle: 'المقدمة',
          introductionDescription:
              'يشرح هذا الدرس ${topicAt(1)} مع أمثلة مبسطة تساعدك على كتابة كود أكثر وضوحا.',
          resources: const [
            ResourceModel(
              id: 'resource_youtube_2',
              type: 'youtube',
              title: 'قناة Elzero Web School',
              link: 'https://www.youtube.com/watch?v=Y8Tko2YC5hA',
            ),
          ],
        ),
        SubLessonModel(
          id: '${prefix}_sub_3',
          title: topicAt(2),
          introductionTitle: 'المقدمة',
          introductionDescription:
              'الجزء الأخير من هذه الوحدة يركز على ${topicAt(2)} مع نقاط مهمة للمراجعة.',
          resources: const [
            ResourceModel(
              id: 'resource_book_2',
              type: 'book',
              title: 'C++ Primer, Fifth Edition',
              link:
                  'https://www.oreilly.com/library/view/c-primer-fifth/9780133053043/',
            ),
          ],
        ),
      ],
    );
  }

  static const List<String> _topics = <String>[
    'المتغيرات وأنواع البيانات',
    'الجمل الشرطية',
    'الحلقات التكرارية',
    'الدوال',
    'المصفوفات',
    'المؤشرات',
    'البرمجة كائنية التوجه',
  ];
}
