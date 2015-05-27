#import <Preferences/Preferences.h>

@interface TrippleMarkPrefsListController: PSListController {
}
@end

@implementation TrippleMarkPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TrippleMarkPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
