# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }

# Keep GPU Delegate classes
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Don't obfuscate TFLite model files
-keep class * extends org.tensorflow.lite.InterpreterApi { *; }
