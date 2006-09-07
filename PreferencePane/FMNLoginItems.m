//
//  FMNLoginItems.m
//  FMN
//
//  Created by Nathaniel Gray on 9/6/06.
//  Copyright 2006 Nathaniel Gray. All rights reserved.
//

#import "FMNLoginItems.h"

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

@end
