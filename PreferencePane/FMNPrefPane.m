//
//  FMNPrefPane.m
//  FMN
//
//  Created by Nathaniel Gray on 8/1/06.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNPrefPane.h"
#import "FMNServer.h"
#import "FMNLoginItems.h"
#import "version.h"

@implementation FMNPrefPane

- (IBAction) launchWebsite:(id)sender
{
    NSString *website = [myBundle objectForInfoDictionaryKey:@"FMNWebsite"];
    if (website == nil || ![website isKindOfClass:[NSString class]]) {
        NSLog(@"Error retrieving website from Info.plist file");
        website = @"http://www.n8gray.org/code";
    }
    website = [NSString stringWithFormat:@"open %@", website];
    system([website cString]);
}

// Returns true if FMN was started or already running, false if it could not be
// started.
- (BOOL) startFMN
{
    return [[NSWorkspace sharedWorkspace] launchApplication:mFMNPath];
}

// If this fails then mFMNProxy will be nil
- (void) connectToRunningFMN
{
    NSConnection *c = 
            [NSConnection connectionWithRegisteredName:@"org.metaprl.ForgetMeNot"
                                                  host:nil];
    mFMNProxy = [[c rootProxy] retain];
    [mFMNProxy setProtocolForProxy:@protocol(FMNServer)];
}

- (void) connectToFMN
{
    [mSpinner startAnimation:self];
    [mStatusField setStringValue:@"Connecting to Forget-Me-Not.app"];
    
    [self connectToRunningFMN];
    if (mFMNProxy == nil) {
        if (![self startFMN]) {
            [mStatusField setStringValue:@"Couldn't launch Forget-Me-Not.app"];
        } else {
            int i;
            for(i=0; mFMNProxy == nil && i<4; i++) {
                sleep(2);
                [self connectToRunningFMN];
            }
            if (mFMNProxy == nil) {
                [mStatusField setStringValue:@"Couldn't connect to Forget-Me-Not.app"];
            } else {
                [mStatusField setStringValue:@"Forget-Me-Not.app Ready."];
            }
        }
    }
    [mSpinner stopAnimation:self];
}

- (BOOL) updateFMNStatus
{
    if (mFMNProxy) {
        [mLaunchQuit setTitle:@"Quit"];
        [mControls setHidden:NO];
        if ([mFMNProxy isActiveFMN]) {
            [mStatusField setStringValue:@"Forget-Me-Not Activated"];
            [mActivated setState:NSOnState];
            [mDiagram setImage:mEnabledImage];
            return YES;
        } else {
            [mStatusField setStringValue:@"Forget-Me-Not Deactivated"];
            [mActivated setState:NSOffState];
            [mDiagram setImage:mDisabledImage];
            return NO;
        }
    } else {
        [mStatusField setStringValue:@"Forget-Me-Not Not Running"];
        [mLaunchQuit setTitle:@"Launch"];
        [mControls setHidden:YES];
        [mDiagram setImage:mDisabledImage];
        return NO;
    }
}

- (IBAction) launchOrQuit:(id)sender
{
    if (mFMNProxy) {
        [mFMNProxy quitFMN];
        [mFMNProxy release];
        mFMNProxy = nil;
    } else {
        [self connectToFMN];
    }
    [self updateFMNStatus];
}

- (IBAction) toggleActivated:(id)sender
{
    if (mFMNProxy) {
        if ([sender state] == NSOnState) {
            if (![mFMNProxy activateFMN])
                [mStatusField setStringValue:@"Error while activating Forget-Me-Not"];
        } else {
            if (![mFMNProxy deactivateFMN])
                [mStatusField setStringValue:@"Error while deactivating Forget-Me-Not"];
        }
        [self updateFMNStatus];
    }
}

// This is called when our pane has been selected
- (void) didSelect
{
    [mVersionLabel setStringValue:
        [NSString stringWithFormat:@"%C Nathaniel Gray\n& David Noblet\nv%@", 
            0x00a9, FMN_VERSION_NSSTRING]];
    if (AXAPIEnabled()) {
        [mAccessWarning setHidden:YES];
        [mLaunchQuit setEnabled:YES];
        [self connectToFMN];
        [self updateFMNStatus];
        [mAutolaunch setState:[FMNLoginItems isLoginItem:@"Forget-Me-Not"]];
    } else {
        [mDiagram setImage:nil];
        [mAccessWarning setHidden:NO];
        [mLaunchQuit setEnabled:NO];
    }
}

// This is called when it's unselected
- (NSPreferencePaneUnselectReply)shouldUnselect
{
    if ([mAutolaunch state] == NSOnState) {
        if (![FMNLoginItems isLoginItem:@"Forget-Me-Not"]) {
            [FMNLoginItems addLoginItem:mFMNPath hidden:NO ];
        }
    } else {
        [FMNLoginItems deleteLoginItem:@"Forget-Me-Not"];
    }
    [mControls setHidden:YES];
    if (mFMNProxy != nil) {
        [mFMNProxy release];
    }
    return NSUnselectNow;
}

- (id) initWithBundle:(NSBundle *)bundle
{
    if ((self = [super initWithBundle:bundle]) == nil) {
        return nil;
    }
    myBundle = [bundle retain];
    mFMNPath = [[myBundle pathForResource:@"Forget-Me-Not" ofType:@"app"] retain];
    mEnabledImage = [[NSImage alloc] 
            initWithContentsOfFile:[myBundle pathForResource:@"diagram-enabled" 
                                                      ofType:@"png"]];
    mDisabledImage = [[NSImage alloc] 
            initWithContentsOfFile:[myBundle pathForResource:@"diagram-disabled" 
                                                      ofType:@"png"]];
    [mDiagram setImage:mDisabledImage];
    return self;
}

- (NSString *)mainNibName
{
    return @"FMNPrefPane";
}

@end
