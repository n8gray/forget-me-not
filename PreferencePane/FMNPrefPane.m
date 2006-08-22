//
//  FMNPrefPane.m
//  FMN
//
//  Created by Nathaniel Gray on 8/1/06.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNPrefPane.h"
#import "FMNServer.h"

@implementation FMNPrefPane

// Returns true if FMN was started or already running, false if it could not be
// started.
- (BOOL) startFMN
{
    return [[NSWorkspace sharedWorkspace] 
            launchApplication:[myBundle pathForResource:@"FMN" ofType:@"app"]];
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
    [mStatusField setStringValue:@"Connecting to FMN.app"];
    
    if (![self startFMN]) {
        [mStatusField setStringValue:@"Couldn't launch FMN.app"];
    } else {
        sleep(1);
        [self connectToRunningFMN];
        if (mFMNProxy == nil) {
            [mStatusField setStringValue:@"Couldn't connect to FMN.app"];
        } else {
            [mStatusField setStringValue:@"FMN.app Ready."];
        }
    }
    [mSpinner stopAnimation:self];
}

- (BOOL) updateFMNStatus
{
    if (mFMNProxy) {
        [mLaunchQuit setTitle:@"Quit FMN"];
        [mControls setHidden:NO];
        if ([mFMNProxy isActiveFMN]) {
            [mStatusField setStringValue:@"FMN Activated"];
            [mActivated setState:NSOnState];
            return YES;
        } else {
            [mStatusField setStringValue:@"FMN Deactivated"];
            [mActivated setState:NSOffState];
            return NO;
        }
    } else {
        [mLaunchQuit setTitle:@"Launch FMN"];
        [mControls setHidden:YES];
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
                [mStatusField setStringValue:@"Error while activating FMN"];
        } else {
            if (![mFMNProxy deactivateFMN])
                [mStatusField setStringValue:@"Error while deactivating FMN"];
        }
        [self updateFMNStatus];
    }
}

// This is called when our pane has been selected
- (void) didSelect
{
    [self connectToFMN];
    [self updateFMNStatus];
}

- (id) initWithBundle:(NSBundle *)bundle
{
    if ((self = [super initWithBundle:bundle]) == nil) {
        return nil;
    }
    myBundle = [bundle retain];
    return self;
}

- (NSString *)mainNibName
{
    return @"FMNPrefPane";
}

@end
