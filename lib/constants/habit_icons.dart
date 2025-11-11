import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Central icon library using Phosphor Icons - elegant and modern icons
class HabitIconLibrary {
  static final List<IconData> icons = [
    // Health & Fitness
    PhosphorIconsRegular.barbell, // Fitness
    PhosphorIconsRegular.footprints, // Running/Exercise
    PhosphorIconsRegular.heart, // Wellness/Spa
    PhosphorIconsRegular.drop, // Water/Hydration
    PhosphorIconsRegular.moon, // Sleep/Bedtime
    PhosphorIconsRegular.forkKnife, // Food/Restaurant
    PhosphorIconsRegular.heartbeat, // Health tracking
    PhosphorIconsRegular.leaf, // Yoga/Stretching (yoga icon doesn't exist, using leaf)
    PhosphorIconsRegular.bicycle, // Cycling
    PhosphorIconsRegular.swimmingPool, // Swimming
    PhosphorIconsRegular.tree, // Nature/Outdoor
    PhosphorIconsRegular.sun, // Morning routine
    
    // Mindfulness & Wellness
    PhosphorIconsRegular.leaf, // Meditation/Mindfulness
    PhosphorIconsRegular.wind, // Breathing
    PhosphorIconsRegular.yinYang, // Balance
    PhosphorIconsRegular.sparkle, // Self-care
    PhosphorIconsRegular.flower, // Calm
    PhosphorIconsRegular.campfire, // Relaxation
    PhosphorIconsRegular.heart, // Peace (wave icon doesn't exist, using heart)
    PhosphorIconsRegular.tree, // Nature connection (mountain icon doesn't exist, using tree)
    
    // Learning & Productivity
    PhosphorIconsRegular.book, // Reading/Learning
    PhosphorIconsRegular.bookOpen, // Reading
    PhosphorIconsRegular.pencil, // Writing/Notes
    PhosphorIconsRegular.code, // Coding
    PhosphorIconsRegular.globe, // Language/Learning
    PhosphorIconsRegular.graduationCap, // Education
    PhosphorIconsRegular.translate, // Language
    PhosphorIconsRegular.notebook, // Journal/Notes
    PhosphorIconsRegular.clipboardText, // Planning
    PhosphorIconsRegular.calendar, // Scheduling
    PhosphorIconsRegular.calendarCheck, // Daily planning
    PhosphorIconsRegular.target, // Goals/Focus
    PhosphorIconsRegular.briefcase, // Work
    PhosphorIconsRegular.lightbulb, // Ideas
    PhosphorIconsRegular.magnifyingGlass, // Research
    PhosphorIconsRegular.chartLine, // Analytics
    PhosphorIconsRegular.timer, // Time management
    
    // Creativity & Arts
    PhosphorIconsRegular.musicNote, // Music
    PhosphorIconsRegular.pencilSimple, // Drawing
    PhosphorIconsRegular.penNib, // Writing
    PhosphorIconsRegular.paintBrush, // Painting
    PhosphorIconsRegular.palette, // Art
    PhosphorIconsRegular.camera, // Photography
    PhosphorIconsRegular.videoCamera, // Video
    PhosphorIconsRegular.microphone, // Recording
    PhosphorIconsRegular.guitar, // Music instrument
    
    // Social & Relationships
    PhosphorIconsRegular.user, // Personal
    PhosphorIconsRegular.users, // Social
    PhosphorIconsRegular.chatCircle, // Communication
    PhosphorIconsRegular.handshake, // Connection
    PhosphorIconsRegular.gift, // Giving
    PhosphorIconsRegular.phone, // Call
    
    // Daily Life & Habits
    PhosphorIconsRegular.house, // Home
    PhosphorIconsRegular.coffee, // Morning routine
    PhosphorIconsRegular.shower, // Self-care
    PhosphorIconsRegular.tooth, // Dental care
    PhosphorIconsRegular.clipboard, // Tasks
    PhosphorIconsRegular.checkCircle, // Completion
    PhosphorIconsRegular.star, // Favorite
    PhosphorIconsRegular.flame, // Streak
    PhosphorIconsRegular.trophy, // Achievement
    PhosphorIconsRegular.medal, // Milestone
    PhosphorIconsRegular.bell, // Reminders
    PhosphorIconsRegular.clock, // Time
    PhosphorIconsRegular.calendarBlank, // Daily
  ];

  static IconData resolve(int? codePoint) {
    if (codePoint == null) {
      return PhosphorIconsRegular.star;
    }
    for (final icon in icons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return PhosphorIconsRegular.star;
  }
}
