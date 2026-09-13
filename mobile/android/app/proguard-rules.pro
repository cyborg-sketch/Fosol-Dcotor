# tflite_flutter's GPU delegate is an optional runtime dependency (only used
# if a device actually has the GPU delegate library available) — R8 can't
# verify that at compile time, so it needs an explicit keep/dontwarn rather
# than failing the release build outright.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-keep class org.tensorflow.lite.gpu.** { *; }
