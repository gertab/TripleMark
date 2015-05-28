@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

static BOOL EnteredSpaceTwice = NO;
static BOOL EnteredSpaceThreeTimes = NO;
static BOOL intelligentMode = NO;


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
    
    if ([text isEqualToString:@" "] && EnteredSpaceThreeTimes && intelligentMode && !firstCharacterWritten && !secondCharacterWritten  && !thirdCharacterWritten && fourthCharacterWritten) { // Three spaces entered
        [self deleteBackward];     
        [self deleteBackward];
        EnteredSpaceThreeTimes = NO;
        %orig(@"? ");
    } else if ([text isEqualToString:@" "] && EnteredSpaceThreeTimes && !intelligentMode) { // Three spaces entered
        [self deleteBackward];     
        [self deleteBackward];
        EnteredSpaceThreeTimes = NO;
        %orig(@"? ");
    } else if (EnteredSpaceTwice) { // Two spaces enteres
        EnteredSpaceThreeTimes = YES;
        EnteredSpaceTwice = NO;
        %orig;
    } else {
        EnteredSpaceThreeTimes = NO;
        %orig;
    }
}
%end 


// settings
@interface NSUserDefaults (CallShortcut)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"me.tabone.tripplemarkprefs";
static NSString *nsNotificationString = @"me.tabone.tripplemarkprefs/changed";


static void loadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSDictionary *prefs;
    NSLog(@"CallShortcut: Loading preferences.");
    //[prefs release];
    CFStringRef appID = CFSTR("me.tabone.tripplemarkprefs");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!keyList) {
        NSLog(@"There's been an error getting the key list!");
        return;
    }
    prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

    if (!prefs) {
        NSLog(@"There's been an error getting the preferences dictionary!");
    }
    CFRelease(keyList);

    NSNumber *n = (NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"intelligentSwitch" inDomain:nsDomainString];
    intelligentMode = n ? [n boolValue] : NO;
    [prefs release];
}
 
%ctor {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    loadPrefs(NULL,NULL,NULL,NULL,NULL);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    [pool release];
}