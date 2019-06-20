#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LIALinkedInApplication.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "LIALinkedInHttpClient.h"
#import "NSString+LIAEncode.h"

FOUNDATION_EXPORT double IOSLinkedInAPIFixVersionNumber;
FOUNDATION_EXPORT const unsigned char IOSLinkedInAPIFixVersionString[];

