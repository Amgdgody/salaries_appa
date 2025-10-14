# ===== Flutter & Google Play Core =====
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===== Keep annotations =====
-keepattributes *Annotation*

# ===== Keep classes with native methods =====
-keepclasseswithmembernames class * {
    native <methods>;
}

# ===== General Android rules =====
-dontwarn com.google.android.play.**
-dontwarn io.flutter.**
