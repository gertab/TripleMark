@interface UIKeyboardImpl : UIView
- (void)deleteBackward;
@end

static BOOL EnteredSpaceTwice = NO;
static BOOL EnteredSpaceThreeTimes = NO;

%hook UIKeyboardImpl
- (id)inputEventForInputString:(NSString *)text
{
    static NSDate *startTime = nil;
    static NSString *prevText = nil;

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
    
    if ([text isEqualToString:@" "] && EnteredSpaceThreeTimes) { // Three spaces entered
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