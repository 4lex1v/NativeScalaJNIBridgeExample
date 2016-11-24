enablePlugins(JniNative)

name := "BridgeExample"

target in javah := sourceDirectory.value / "native" / "include"
