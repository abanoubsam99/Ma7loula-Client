# Keep kotlinx.parcelize
-keep class kotlinx.parcelize.** { *; }

# Keep SLF4J Logger classes
-keep class org.slf4j.** { *; }

# Keep Giphy SDK Analytics models
-keep class com.giphy.sdk.analytics.models.** { *; }

-dontwarn kotlinx.parcelize.Parcelize
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn com.stripe.**
-dontwarn com.facebook.imagepipeline.nativecode.WebpTranscoder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions