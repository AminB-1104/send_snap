# Keep ML Kit text recognition classes
-keep class com.google.mlkit.vision.text.** { *; }

# Keep Google ML Kit common classes
-keep class com.google.mlkit.common.** { *; }

# Prevent warnings about ML Kit
-dontwarn com.google.mlkit.**
