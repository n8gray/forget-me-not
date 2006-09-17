//
//  FMNLoginItems.m
//  FMN
//
//  Created by Nathaniel Gray on 9/6/06.
//  Copyright 2006 Nathaniel Gray. All rights reserved.
//

#import "FMNLoginItems.h"
#import "FMNPrefPane.h"

@implementation FMNLoginItems

+ (BOOL) isLoginItem:(NSString *)appName
{
    NSString *s = [NSString stringWithFormat:
        @"tell application \"System Events\"\n"
        @"\texists login item \"%@\"\n"
        @"end tell\n", appName];
    NSAppleScript *scriptObj = [[NSAppleScript alloc] initWithSource:s];
    if (scriptObj) {
        NSDictionary *errInfo;
        NSAppleEventDescriptor *aed = [scriptObj executeAndReturnError:&errInfo];
        [scriptObj release];
        if (aed) {
            return [aed booleanValue];
        }
    }
    NSLog(@"Got Error in isLoginItem");
    return NO;
}

+ (void) deleteLoginItem:(NSString *)appName
{
    NSString *s = [NSString stringWithFormat:
        @"tell application \"System Events\"\n"
        @"\tdelete login item \"%@\"\n"
        @"end tell\n", appName];
    NSAppleScript *scriptObj = [[NSAppleScript alloc] initWithSource:s];
    if (scriptObj) {
        NSDictionary *errInfo;
        NSAppleEventDescriptor *aed = [scriptObj executeAndReturnError:&errInfo];
        [scriptObj release];
        if (aed) {
            return;
        }
    }
    NSLog(@"Got Error in deleteLoginItem");
    return;
}

+ (BOOL) addLoginItem:(NSString *)appPath hidden:(BOOL)hidden
{
    NSString *s = [NSString stringWithFormat:
        @"set appPath to \"%@\"\n"
        @"tell application \"System Events\"\n"
        @"\tmake login item at end with properties {path:appPath, hidden:%@}\n"
        @"end tell\n", appPath, hidden ? @"true" : @"false"];
    NSAppleScript *scriptObj = [[NSAppleScript alloc] initWithSource:s];
    if (scriptObj) {
        NSDictionary *errInfo;
        NSAppleEventDescriptor *aed = [scriptObj executeAndReturnError:&errInfo];
        [scriptObj release];
        if (aed) {
            return YES;
        }
    }
    NSLog(@"Got Error in isLoginItem");
    return NO;
}

- (void) notifyWillSelect
{
    
}

- (void) notifyDidSelect
{
     if (AXAPIEnabled()) {
        [mAutolaunch setState:[FMNLoginItems isLoginItem:@"Forget-Me-Not"]];
    }
}

- (void) notifyUnselected
{
    if ([mAutolaunch state] == NSOnState) {
        if (![FMNLoginItems isLoginItem:@"Forget-Me-Not"]) {
            [FMNLoginItems addLoginItem:mFMNPath hidden:NO ];
        }
    } else {
        if ([FMNLoginItems isLoginItem:@"Forget-Me-Not"]) {
            [FMNLoginItems deleteLoginItem:@"Forget-Me-Not"];
        }
    }
}

- (id) initWithBundle: (NSBundle*) bundle
{
    self = [super init];
    if (!self)
        return nil;
    
    NSString* myBundlePath = [bundle bundlePath];
    NSString* parentBundlePath = [NSString stringWithFormat:@"%@/../../../",myBundlePath];
    mFMNPath = [[NSBundle pathForResource:@"Forget-Me-Not" ofType:@"app" inDirectory: parentBundlePath] retain];
    
    // Load our nib
    [NSBundle loadNibNamed:@"AutolaunchPrefpaneModule" owner:self];
    
    return self;
}

- (NSView*) getControlView
{
    return [mAutolaunch retain];

    /*NSButton* newButton;
    NSSize size;

    newButton = [[NSButton alloc] init];
    [newButton setButtonType:NSSwitchButton];
    //[newButton setTitle: @"Autoload Prefpane Module"];
    [newButton setTitle: mFMNPath];
    size.width = 240;
    size.height = 20;
    [newButton setFrameSize: size];

    return newButton;*/
}

- (BOOL) isTabControl
{
    return NO;
}

@end
