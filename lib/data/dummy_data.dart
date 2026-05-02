import 'package:flutter/material.dart';
import '../models/models.dart';

final List<Category> dummyCategories = [
  Category(id: 'all', name: 'All', icon: '📱'),
  Category(id: 'gm', name: 'Good Morning', icon: '🌅'),
  Category(id: 'gn', name: 'Good Night', icon: '🌙'),
  Category(id: 'sv', name: 'Suvichar', icon: '💡'),
  Category(id: 'qt', name: 'Quotes', icon: '📜'),
  Category(id: 'bd', name: 'Birthday', icon: '🎂'),
];

final List<Quote> dummyQuotes = [
  Quote(id: 'q1', text: 'शिक्षित बनो, संगठित रहो, संघर्ष करो।', categoryId: 'qt'),
  Quote(id: 'q2', text: 'मैं उस धर्म को पसंद करता हूँ जो स्वतंत्रता, समानता और भाईचारा सिखाता है।', categoryId: 'sv'),
  Quote(id: 'q3', text: 'जीवन लंबा होने के बजाय महान होना चाहिए।', categoryId: 'sv'),
  Quote(id: 'q4', text: 'बुद्धि का विकास मानव के अस्तित्व का अंतिम लक्ष्य होना चाहिए।', categoryId: 'qt'),
  Quote(id: 'q5', text: 'एक महान आदमी एक प्रतिष्ठित आदमी से इस तरह अलग होता है कि वह समाज का सेवक बनने के लिए तैयार रहता है।', categoryId: 'sv'),
  Quote(id: 'q6', text: 'शुभ प्रभात! जय भीम।', categoryId: 'gm'),
  Quote(id: 'q7', text: 'शुभ रात्रि! नमो बुद्धाय।', categoryId: 'gn'),
];

final UserProfile dummyUser = UserProfile(
  name: 'Rahul Kumar',
  subtitle: 'Jai Bhim Enthusiast',
);

final List<TemplateModel> dummyTemplates = [
  // All / General
  TemplateModel(id: 't1', name: 'Indigo', backgroundColor: const Color(0xFF3F51B5), textColor: Colors.white, categoryId: 'all'),
  TemplateModel(id: 't2', name: 'Saffron', backgroundColor: const Color(0xFFFF9800), textColor: Colors.white, categoryId: 'all', isPremium: true, gradientColors: [const Color(0xFFFF9800), const Color(0xFFF44336)]),
  
  // Good Morning
  TemplateModel(id: 't3', name: 'Sunrise', backgroundColor: const Color(0xFFFFAB40), textColor: Colors.black, categoryId: 'gm', gradientColors: [const Color(0xFFFFD180), const Color(0xFFFFAB40)]),
  TemplateModel(id: 't4', name: 'Morning Sky', backgroundColor: const Color(0xFF81D4FA), textColor: Colors.white, categoryId: 'gm', isPremium: true, gradientColors: [const Color(0xFF81D4FA), const Color(0xFF01579B)]),

  // Good Night
  TemplateModel(id: 't5', name: 'Midnight', backgroundColor: const Color(0xFF1A237E), textColor: Colors.white, categoryId: 'gn', gradientColors: [const Color(0xFF1A237E), const Color(0xFF000000)]),
  TemplateModel(id: 't6', name: 'Starry', backgroundColor: const Color(0xFF311B92), textColor: Colors.white, categoryId: 'gn', isPremium: true),

  // Suvichar
  TemplateModel(id: 't7', name: 'Wisdom', backgroundColor: const Color(0xFF4E342E), textColor: Colors.white, categoryId: 'sv'),
  TemplateModel(id: 't8', name: 'Growth', backgroundColor: const Color(0xFF2E7D32), textColor: Colors.white, categoryId: 'sv', isPremium: true, gradientColors: [const Color(0xFF81C784), const Color(0xFF2E7D32)]),

  // Quotes
  TemplateModel(id: 't9', name: 'Modern', backgroundColor: const Color(0xFF263238), textColor: Colors.white, categoryId: 'qt'),
  TemplateModel(id: 't10', name: 'Clean', backgroundColor: const Color(0xFFECEFF1), textColor: Colors.black, categoryId: 'qt', isPremium: true),

  // Birthday
  TemplateModel(id: 't11', name: 'Party', backgroundColor: const Color(0xFFE91E63), textColor: Colors.white, categoryId: 'bd', gradientColors: [const Color(0xFFF06292), const Color(0xFFE91E63)]),
  TemplateModel(id: 't12', name: 'Gold', backgroundColor: const Color(0xFFFFD700), textColor: Colors.black, categoryId: 'bd', isPremium: true, gradientColors: [const Color(0xFFFFF176), const Color(0xFFFFD700)]),
];
