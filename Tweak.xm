#define log(BOOL) BOOL ? @"YES" : @"NO"
#include <CoreFoundation/CFNotificationCenter.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSString.h>

// Settings variables
static NSString *textToPrint;


@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

static BOOL EnteredSpaceTwice = NO;
static BOOL EnteredSpaceThreeTimes = NO;

// Keeping count of the previous characters written to prevent multiple inputs of the question mark when unnecessary
// If not a valid character (e.g. "?" or " ") -> NO
static BOOL firstCharacterWritten = NO;
static BOOL secondCharacterWritten = NO;
static BOOL thirdCharacterWritten = NO;
static BOOL fourthCharacterWritten = NO;
static BOOL tempCharacterWritten = NO;


%hook UIKeyboardImpl
- (id)inputEventForInputString:(NSString *)text
{
    static NSDate *startTime = nil;
    static NSString *prevText = nil;

    // Check whether the characters written are valid or not
    NSRange invalidCharacters = [text rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890{}[]()<>*';:@&=+$/%#-\""] invertedSet]];

    if (invalidCharacters.location != NSNotFound) {
        tempCharacterWritten = NO;  // invalid
    } else {
        tempCharacterWritten = YES; // valid
    }

    // Moving all variables by 1: 3->4, 2->3...
    fourthCharacterWritten = thirdCharacterWritten;
    thirdCharacterWritten = secondCharacterWritten;
    secondCharacterWritten = firstCharacterWritten;
    firstCharacterWritten = tempCharacterWritten;

    if (!EnteredSpaceThreeTimes && startTime && prevText) {
        NSTimeInterval elapsedTime = -1.0 * [startTime timeIntervalSinceNow];
        EnteredSpaceTwice = (elapsedTime < 0.2 && [text isEqualToString:@" "] && [prevText isEqualToString:text]) ? YES : NO;
        [startTime release];
        [prevText release];
    }

    prevText = [text copy];
    startTime = [[NSDate date] retain];

    return %orig;
}

- (void)insertText:(NSString *)text
{
    
    if ([text isEqualToString:@" "] && EnteredSpaceThreeTimes && !firstCharacterWritten && !secondCharacterWritten  && !thirdCharacterWritten && fourthCharacterWritten) {
        // Should replace " " with "?" only if the user has written any character(s) before (exlude multiple consecutive"?"s)
        [self deleteBackward];     
        [self deleteBackward];
        EnteredSpaceThreeTimes = NO;

        %orig(textToPrint);
    } else if (EnteredSpaceThreeTimes && !([textToPrint isEqualToString:@"?"] || [textToPrint isEqualToString:@"!"] || [textToPrint isEqualToString:@"? "] || [textToPrint isEqualToString:@"! "] || [textToPrint isEqualToString:@"?  "] || [textToPrint isEqualToString:@"!  "])) {
        [self deleteBackward];     
        [self deleteBackward];
        EnteredSpaceThreeTimes = NO;

        %orig(textToPrint);
    } else if (EnteredSpaceTwice) { 
        EnteredSpaceThreeTimes = YES;
        EnteredSpaceTwice = NO;
        %orig;
    } else {
        EnteredSpaceThreeTimes = NO;
        %orig;
    }
}
%end


// Settings



 static NSString *domainString = @"me.tabone.triplemarkprefs";
static NSString *notificationString = @"me.tabone.triplemarkprefs/preferences.changed";
@interface NSUserDefaults (TripleM)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *n = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"text" inDomain:domainString];
    textToPrint = [n copy];
    if ([textToPrint length] == 0)
    {
        textToPrint = @"?...";
    }
}

%ctor {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    //set initial `enable' variable
    notificationCallback(NULL, NULL, NULL, NULL, NULL);

    //register for notifications
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    [pool release];
}

/*
static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:domainString];

    textToPrint = [dict objectForKey:@"text"];
    if ([textToPrint isEqualToString:@""])
    {
        textToPrint = @"?....";
    }
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadSettings();
}

%ctor
{
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("me.tabone.triplemarkprefs/preferences.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadSettings();
    }
}*/