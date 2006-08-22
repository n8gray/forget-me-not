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
    //[mSpinner setHidden:NO];
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
    //[mSpinner setHidden:YES];
}

- (IBAction) toggleActivated:(id)sender
{
    if (mFMNProxy) {
        if ([sender state] == NSOnState) {
            if ([mFMNProxy activateFMN])
                [mStatusField setStringValue:@"FMN Activated"];
            else
                [mStatusField setStringValue:@"Error while activating FMN"];
        } else {
            if ([mFMNProxy deactivateFMN])
                [mStatusField setStringValue:@"FMN Deactivated"];
            else
                [mStatusField setStringValue:@"Error while deactivating FMN"];
        }
    }
}

// This is called when our pane has been selected
- (void) didSelect
{
    [self connectToFMN];
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
