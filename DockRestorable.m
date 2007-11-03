//
//  DockRestorable.m
//  FMN
//
//  Created by David Noblet on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DockRestorable.h"

#define DOCK CFSTR("com.apple.dock")
#define USER kCFPreferencesCurrentUser
#define HOST kCFPreferencesAnyHost
#define AUTOHIDE CFSTR("autohide")

@implementation DockRestorable

/*- (void) logDockPrefs
{
    NSEnumerator *enumerator = [dockPrefs keyEnumerator];
    id key;
   
    while ((key = [enumerator nextObject])) 
    {
        id value = [dockPrefs valueForKey: key];
        NSLog(@"@@@@@@@@@@ Key: '%@'; Value: '%@' @@@@@@@@@@@@@", key, value);
    }
}*/

+ (Boolean) getDockAutohide
{
    Boolean success;
    return CFPreferencesGetAppBooleanValue (
        AUTOHIDE,
        DOCK,
        &success
    ) && success;
}

- (id) initWithCurrent
{
    self = [super init];
    if(!self)
        return nil;
        
    NSLog(@"Storing Dock Preferences");
    
    CFPreferencesAppSynchronize(DOCK);
    
    /*NSArray* keys;
    keys = (NSArray*) CFPreferencesCopyKeyList (
        DOCK,
        USER,
        HOST
    );
    
    dockPrefs = (NSDictionary*) CFPreferencesCopyMultiple (
        (CFArrayRef) keys,
        DOCK,
        USER,
        HOST
    );
    [keys release];*/
    
    autohidePref = [DockRestorable getDockAutohide];
    
    NSLog(@"Storing Dock Autohide Preference: %d",autohidePref);
    
    //[self logDockPrefs];
        
    return self;
}

- (void) restoreWithContext : (NSDictionary*) context
{
    NSLog(@"Restoring Dock Preferences");
    /*[self logDockPrefs];
    
    CFPreferencesSetMultiple (
        (CFDictionaryRef) dockPrefs,
        nil,
        DOCK,
        USER,
        HOST
    );*/
    
    NSLog(@"Restoring Dock Autohide Preference: %d",autohidePref);
    
    if([DockRestorable getDockAutohide] != autohidePref)
    {
        CFPreferencesSetValue(
            AUTOHIDE, 
            autohidePref ? kCFBooleanTrue : kCFBooleanFalse, 
            DOCK, 
            USER, 
            HOST
        );
        
        CFPreferencesAppSynchronize(DOCK);

        /*CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
        CFNotificationCenterPostNotification (
            center,
            CFSTR("com.apple.dock.prefchanged"),
            DOCK,
            nil, true
        );*/
        
        /*
        tell application "System Events"
            keystroke "d" using {command down, option down}
        end tell
        */
        
        NSString *s = [NSString stringWithFormat:
            @"tell application \"System Events\"\n"
            @"\tkeystroke \"d\" using {command down, option down}\n"
            @"end tell\n"];
        NSAppleScript *scriptObj = [[NSAppleScript alloc] initWithSource:s];
        if (scriptObj) 
        {
            NSDictionary *errInfo;
            NSAppleEventDescriptor *aed = [scriptObj executeAndReturnError:&errInfo];
            [scriptObj release];
            if (!aed)
            {
                NSLog(@"Got Error in deleteLoginItem");
            }
        }
    }
}

- (int) priority
{
    // We want this to be restored before the window positions and sizes
    return kRestorableDefaultPriority+1;
}

- (void) dealloc
{
    /*if(dockPrefs)
    {
        [dockPrefs release];
    }*/
    [super dealloc];
}

@end
