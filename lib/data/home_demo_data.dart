// Demo data for the home page
class HomePageDemoData {
  // Featured courses for the carousel slider
  static final List<Map<String, dynamic>> featuredCourses = [
    {
      'title': 'تعلم أساسيات البرمجة',
      'instructor': 'أحمد محمد',
      'image': 'assets/images/f1.png',
      'description': 'دورة شاملة لتعلم أساسيات البرمجة للمبتدئين',
      'tags': ['جديد', 'برمجة'],
    },
    {
      'title': 'تطوير تطبيقات الويب',
      'instructor': 'سارة أحمد',
      'image': 'assets/images/f2.png',
      'description': 'تعلم كيفية تطوير تطبيقات الويب الحديثة',
      'tags': ['تطوير', 'ويب'],
    },
    {
      'title': 'تصميم واجهات المستخدم',
      'instructor': 'محمد علي',
      'image': 'assets/images/f3.png',
      'description': 'دورة متقدمة في تصميم واجهات المستخدم',
      'tags': ['تصميم', 'UI/UX'],
    },
    {
      'title': 'التسويق الرقمي',
      'instructor': 'ليلى حسن',
      'image': 'assets/images/co3.png',
      'description': 'استراتيجيات التسويق الرقمي الحديثة',
      'tags': ['تسويق', 'ديجيتال'],
    },
  ];

  // Regular courses for horizontal lists
  static final List<Map<String, dynamic>> courses = [
    {
      'title': 'مبادئ البرمجة بلغة Python',
      'instructor': 'أحمد محمد',
      'image': 'assets/images/co1.png',
      'tags': ['برمجة', 'مبتدئ'],
    },
    {
      'title': 'تطوير تطبيقات الموبايل',
      'instructor': 'سارة أحمد',
      'image': 'assets/images/co2.png',
      'tags': ['تطوير', 'موبايل'],
    },
    {
      'title': 'تصميم الجرافيك',
      'instructor': 'محمد علي',
      'image': 'assets/images/co3.png',
      'tags': ['تصميم', 'جديد'],
    },
    {
      'title': 'إدارة المشاريع',
      'instructor': 'ليلى حسن',
      'image': 'assets/images/num1.png',
      'tags': ['إدارة', 'أعمال'],
    },
    {
      'title': 'التسويق عبر وسائل التواصل الاجتماعي',
      'instructor': 'عمر خالد',
      'image': 'assets/images/num2.png',
      'tags': ['تسويق', 'اجتماعي'],
    },
  ];

  // Learning programs
  static final List<Map<String, dynamic>> learningPrograms = [
    {
      'title': 'برنامج تطوير الويب الشامل',
      'description': 'تعلم تطوير الويب من الصفر إلى الاحتراف',
      'imageUrl': 'assets/images/prog1.png',
      'buttonText': 'ابدأ الآن',
      'coursesCount': 5,
    },
    {
      'title': 'برنامج التسويق الرقمي',
      'description': 'كل ما تحتاجه لتصبح خبير تسويق رقمي',
      'imageUrl': 'assets/images/prog2.png',
      'buttonText': 'ابدأ الآن',
      'coursesCount': 4,
    },
    {
      'title': 'برنامج تطوير الذات',
      'description': 'تطوير المهارات الشخصية والقيادية',
      'imageUrl': 'assets/images/prog3.png',
      'buttonText': 'ابدأ الآن',
      'coursesCount': 3,
    },
  ];

  // Most watched courses
  static final List<Map<String, dynamic>> mostWatched = [
    {
      'title': 'أساسيات الذكاء الاصطناعي',
      'instructor': 'د. أحمد سامي',
      'image': 'assets/images/teacher1.png',
      'views': 15000,
    },
    {
      'title': 'مهارات التواصل الفعال',
      'instructor': 'سارة محمود',
      'image': 'assets/images/teacher2.png',
      'views': 12000,
    },
    {
      'title': 'تعلم اللغة الإنجليزية للمبتدئين',
      'instructor': 'محمد عادل',
      'image': 'assets/images/teacher3.png',
      'views': 10000,
    },
    {
      'title': 'أساسيات المحاسبة',
      'instructor': 'ليلى كريم',
      'image': 'assets/images/teacher4.png',
      'views': 9500,
    },
  ];
}
