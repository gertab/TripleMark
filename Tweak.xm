#define log(BOOL) BOOL ? @"YES" : @"NO"

@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

static BOOL isDoubleEntering = NO;
static BOOL isTrippleEntering = NO;

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

    if (!isTrippleEntering && startTime && prevText) {
        NSTimeInterval elapsedTime = -1.0 * [startTime timeIntervalSinceNow];
        isDoubleEntering = (elapsedTime < 0.2 && [text isEqualToString:@" "] && [prevText isEqualToString:text]) ? YES : NO;
        [startTime release];
        [prevText release];
    }

    prevText = [text copy];
    startTime = [[NSDate date] retain];

    return %orig;
}

- (void)insertText:(NSString *)text
{
    if ([text isEqualToString:@" "] && isTrippleEntering && !firstCharacterWritten && !secondCharacterWritten  && !thirdCharacterWritten && fourthCharacterWritten) {
        // Should replace " " with "?" only if the user has written any character(s) before (exlude multiple consecutive"?"s)
        [self deleteBackward];     
        [self deleteBackward];
        isTrippleEntering = NO;

        %orig(@"? ");
    } else if (isDoubleEntering) { 
        isTrippleEntering = YES;
        isDoubleEntering = NO;
        %orig;
    } else {
        isTrippleEntering = NO;
        %orig;
    }
}
%end