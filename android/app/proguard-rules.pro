# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom model classes
-keep class com.example.bootstrap_app.models.** { *; }

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ============================================
# Flutter Plugin Rules
# ============================================

# Share Plus plugin
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class androidx.core.content.FileProvider { *; }
-keep class androidx.core.content.FileProvider$* { *; }

# Path Provider plugin
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class androidx.documentfile.provider.** { *; }

# Shared Preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$* { *; }
-keepclassmembers class * implements android.content.SharedPreferences {
    <methods>;
}

# Keep all Flutter plugin classes
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep native method registration
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep reflection-based code (used by plugins)
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault

