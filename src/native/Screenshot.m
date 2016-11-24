#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>
#include "include/bridge_Screenshot__.h"

NSDictionary* findAppWindow(NSString* appName) {
    NSDictionary *gameWindow = nil;

    @autoreleasepool {
        NSArray *windowInfos = (__bridge_transfer NSArray *) CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        for (NSDictionary *windowInfo in windowInfos) {
            NSString *windowName = windowInfo[(__bridge NSString *) kCGWindowName];
            if ([windowName isEqual: appName]) {
                gameWindow = windowInfo;
                break;
            }
        }
    }

    return gameWindow;
}

NSMutableData* makeScreenshot(NSDictionary* appWindow) {
    int windowID = [appWindow[(__bridge NSString*)kCGWindowNumber] intValue];
    CGImageRef  imageRef = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageBoundsIgnoreFraming);

    NSMutableData* imgData = [[NSMutableData alloc] init];

    CFStringRef imgFormat = kUTTypeJPEG;
    CGImageDestinationRef imgDest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) imgData, imgFormat, 1, NULL);
    CGImageDestinationAddImage(imgDest, imageRef, NULL);
    BOOL finalizeRes = CGImageDestinationFinalize(imgDest);
    if (!finalizeRes) return NULL;

    return imgData;
}

/*
 * Class:     hearthai_internal_SystemIO__
 * Method:    readSnapshot
 * Signature: ()[B
 */
JNIEXPORT jbyteArray JNICALL Java_bridge_Screenshot_00024_forApp (JNIEnv* jenv, jobject companion, jstring javaStringName) {
  @autoreleasepool {
    NSString* appName = [NSString stringWithUTF8String:(*jenv)->GetStringUTFChars(jenv, javaStringName, 0)];

    NSDictionary *window = findAppWindow(appName);
    if (![window isEqual: NULL]) {
      NSMutableData* imageData = makeScreenshot(window);
      if (![imageData isEqual: NULL]) {
        jbyteArray res = (*jenv)->NewByteArray(jenv, (jsize) imageData.length);
        (*jenv)->SetByteArrayRegion(jenv, res, 0, (jsize) imageData.length, imageData.bytes);
        return res;    
      } else {
        return NULL;
      }
    } else {
      return NULL;
    }
  }

}
