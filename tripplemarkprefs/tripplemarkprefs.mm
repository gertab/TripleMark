#import <Preferences/Preferences.h>

@interface tripplemarkprefsListController: PSListController {
}
@end

@implementation tripplemarkprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"tripplemarkprefs" target:self] retain];
	}
	return _specifiers;
}
-(void)mailGertab {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:gerardtabone+TM@gmail.com"]];
}

-(void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KZ9G6S6W8XKL6"]];
}
@end

// vim:ft=objc

#import <Preferences/PSTableCell.h>
#import <Preferences/PSListController.h>
#import <Preferences/Preferences.h>
int width = [[UIScreen mainScreen] bounds].size.width;


@interface PSTableCell (TM)
-(id)initWithStyle:(long long)style reuseIdentifier:(id)arg2;
@end

@protocol PreferencesTableCustomView
-(id)initWithSpecifier:(id)arg1;

@optional
-(CGFloat)preferredHeightForWidth:(CGFloat)arg1;
-(CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface tripleMarkCustomCell : PSTableCell <PreferencesTableCustomView> {
    UILabel *_label;
    UILabel *underLabel;
}
@end

@implementation tripleMarkCustomCell
-(id)initWithSpecifier:(PSSpecifier *)specifier
{
    //self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self) {
        CGRect frame = CGRectMake(0, -15, width, 60);
        CGRect botFrame = CGRectMake(0, 20, width, 60);
 
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setNumberOfLines:1];
        _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
        [_label setText:@"TripleMark"];
        [_label setBackgroundColor:[UIColor clearColor]];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;

        underLabel = [[UILabel alloc] initWithFrame:botFrame];
        [underLabel setNumberOfLines:1];
        underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [underLabel setText:@"gertab"];
        [underLabel setBackgroundColor:[UIColor clearColor]];
        underLabel.textColor = [UIColor grayColor];
        underLabel.textAlignment = NSTextAlignmentCenter;

 
        [self addSubview:_label];
        [self addSubview:underLabel];
        //[_label release];
        //[underLabel release];
    }
    return self;
}
-(CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    CGFloat prefHeight = 90.0;
    return prefHeight;
}
@end