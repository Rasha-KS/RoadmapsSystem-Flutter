class RoadmapDisplay {
  static String level(String? value) {
    final text = _normalize(value);
    switch (text.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return 'مبتدئ';
      case 'intermediate':
      case 'متوسط':
        return 'متوسط';
      case 'advanced':
      case 'متقدم':
        return 'متقدم';
      default:
        return text.isEmpty ? 'غير محدد' : text;
    }
  }

  static String status(String? value) {
    final text = _normalize(value);
    switch (text.toLowerCase()) {
      case 'active':
      case 'مفعّل':
      case 'subscribed':
      case 'enrolled':
      case 'مشترك':
        return 'مشترك';
      case 'in progress':
      case 'ongoing':
      case 'متابع':
      case 'في تقدم':
        return 'في تقدم';
      case 'completed':
      case 'done':
      case 'مكتمل':
        return 'مكتمل';
      case 'inactive':
      case 'disabled':
      case 'غير نشط':
        return 'غير نشط';
      default:
        return text.isEmpty ? 'غير محدد' : text;
    }
  }

  static String _normalize(String? value) {
    return value?.trim() ?? '';
  }
}
