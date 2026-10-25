// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'GOLDEN GOAL';

  @override
  String get noRouteFound => 'الصفحة غير موجودة';

  @override
  String get home => 'الرئيسية';

  @override
  String get fixtures => 'المباريات';

  @override
  String get standings => 'الترتيب';

  @override
  String get liveScore => 'GOLDEN GOAL';

  @override
  String get versus => 'ضد';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get lineups => 'التشكيل';

  @override
  String get events => 'الأحداث';

  @override
  String get assist => 'صناعة هدف';

  @override
  String get viewFixtures => 'عرض المباريات';

  @override
  String get viewStandings => 'عرض الترتيب';

  @override
  String get liveFixtures => 'المباريات المباشرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get reload => 'إعادة المحاولة';

  @override
  String get noStats => 'لا توجد إحصائيات متاحة حالياً';

  @override
  String get noLineups => 'لا يوجد تشكيل متاح حالياً';

  @override
  String get noEvents => 'لا توجد أحداث متاحة حالياً';

  @override
  String get noFixtures => 'لا توجد مباريات اليوم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceDescription => 'اختَر شكل التطبيق في كل الشاشات.';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get systemDefault => 'حسب الجهاز';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get languageDescription =>
      'اختَر لغة التطبيق أو اجعله يتبع لغة الجهاز.';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get topStats => 'أبرز الإحصائيات';

  @override
  String get teamName => 'الفريق';

  @override
  String get form => 'النتائج';

  @override
  String get playedShort => 'لعب';

  @override
  String get wonShort => 'ف';

  @override
  String get drawnShort => 'ت';

  @override
  String get lostShort => 'خ';

  @override
  String get goalsForShort => 'له';

  @override
  String get goalsAgainstShort => 'عليه';

  @override
  String get goalDifferenceShort => 'فارق';

  @override
  String get pointsShort => 'نقاط';

  @override
  String get tbd => 'لاحقاً';

  @override
  String get liveFallback => 'مباشر';

  @override
  String aggregateScore(Object homeScore, Object awayScore) {
    return 'النتيجة الإجمالية ($homeScore - $awayScore)';
  }

  @override
  String roundNumber(Object number) {
    return 'الجولة $number';
  }

  @override
  String seasonNumber(Object number) {
    return 'الموسم $number';
  }

  @override
  String get errorClientClosedRequest =>
      'حدثت مشكلة أثناء تحميل التفاصيل. حاول مرة أخرى.';

  @override
  String get errorInternalServerError => 'حدث خطأ ما. حاول مرة أخرى لاحقاً.';

  @override
  String get errorNetworkConnectError =>
      'انتهت مهلة الاتصال. تأكد من الإنترنت ثم حاول مرة أخرى.';

  @override
  String get errorWebProxyRequired =>
      'نسخة الويب من Flutter تحتاج إلى Proxy للخادم لهذا الـ API.';

  @override
  String get errorUnexpected => 'حدث خطأ غير متوقع.';

  @override
  String get errorLoadFixtures => 'تعذر تحميل المباريات حالياً.';

  @override
  String get noStandingsYet => 'لا يوجد ترتيب متاح حالياً.';

  @override
  String get errorLoadStandings => 'تعذر تحميل الترتيب حالياً.';

  @override
  String get all => 'الكل';

  @override
  String get allLeaguesTooltip => 'كل الدوريات';

  @override
  String get fullLineups => 'التشكيل الكامل';

  @override
  String get channels => 'القنوات';

  @override
  String get watchLive => 'شاهد مباشر';

  @override
  String get searchChannels => 'بحث في القنوات';

  @override
  String get noChannels => 'لا توجد قنوات متاحة';
}
