import 'dart:math';

/// Service for providing daily motivation quotes
class MotivationService {
  static final List<String> _quotes = [
    // Success & Achievement
    "Small steps lead to big changes. Keep going!",
    "Progress, not perfection. Every day counts.",
    "You're building something amazing, one habit at a time.",
    "Consistency beats intensity. Stay the course.",
    "Your future self will thank you for today's effort.",
    
    // Persistence & Resilience
    "Don't stop when you're tired. Stop when you're done.",
    "The only bad workout is the one that didn't happen.",
    "Fall seven times, stand up eight.",
    "It's not about being perfect, it's about being better.",
    "Every expert was once a beginner.",
    
    // Mindset & Growth
    "Your habits shape your identity. Choose wisely.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "You don't have to be great to start, but you have to start to be great.",
    "Success is the sum of small efforts repeated day in and day out.",
    "The only way to do great work is to love what you do.",
    
    // Health & Wellness
    "Take care of your body. It's the only place you have to live.",
    "Health is wealth. Invest in yourself daily.",
    "Your body can do it. It's your mind you need to convince.",
    "Wellness is not a destination, it's a way of life.",
    "Self-care is not selfish. It's essential.",
    
    // Productivity & Focus
    "Focus on progress, not perfection.",
    "Done is better than perfect.",
    "The secret of getting ahead is getting started.",
    "Productivity is never an accident. It's always the result of commitment.",
    "Time is your most valuable asset. Invest it wisely.",
    
    // Learning & Growth
    "Learning never exhausts the mind.",
    "The more you learn, the more you earn.",
    "Invest in yourself. Your career is the engine of your wealth.",
    "Knowledge is power, but enthusiasm pulls the switch.",
    "Live as if you were to die tomorrow. Learn as if you were to live forever.",
    
    // Motivation & Inspiration
    "You are capable of amazing things.",
    "Believe you can and you're halfway there.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "Dream big. Start small. Act now.",
    "You miss 100% of the shots you don't take.",
    
    // Habit-Specific
    "One habit at a time. One day at a time.",
    "Your habits are your future. Make them count.",
    "The chains of habit are too weak to be felt until they are too strong to be broken.",
    "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
    "Good habits formed at youth make all the difference.",
    
    // Daily Motivation
    "Today is a new beginning. Make it count.",
    "Every sunrise is a new opportunity to be better.",
    "Yesterday is history. Tomorrow is a mystery. Today is a gift.",
    "Make today so awesome that yesterday gets jealous.",
    "The best preparation for tomorrow is doing your best today.",
  ];

  static final Random _random = Random();

  /// Get a random motivation quote
  static String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Get quote of the day (based on date seed for consistency)
  static String getQuoteOfDay() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    return _quotes[random.nextInt(_quotes.length)];
  }

  /// Get quote by category (if needed in future)
  static String getQuoteByCategory(String category) {
    // For now, return random quote
    // Can be enhanced with category-based quotes
    return getRandomQuote();
  }
}

