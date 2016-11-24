package bridge

import ch.jodersky.jni.nativeLoader

@nativeLoader("bridge1")
object Screenshot  {
  @native def forApp(appName: String): Array[Byte]
}
