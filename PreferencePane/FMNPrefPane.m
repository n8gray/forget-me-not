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

/* Login Item manipulation code from some random bulletin board somewhere */
void addToLoginItems( NSString* path, BOOL hide) {
    NSString *loginwindow = @"loginwindow";
    NSUserDefaults *userDefs;
    NSMutableDictionary *dict;
    NSDictionary *entry;
    NSMutableArray *launchItems;
    /* get data from user defaults (~/Library/Preferences/loginwindow.plist) */
    userDefs = [[NSUserDefaults alloc] init];
    if( !(dict = [[userDefs persistentDomainForName:loginwindow] 
            mutableCopyWithZone:NULL]) )
        dict = [[NSMutableDictionary alloc] initWithCapacity:1];
    if( !(launchItems = 
          [[dict objectForKey:@"AutoLaunchedApplicationDictionary"]
                    mutableCopyWithZone:NULL]) )
        launchItems = [[NSMutableArray alloc] initWithCapacity:1];
    /* build entry */
    entry = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSNumber numberWithBool:hide], @"Hide",
        path, @"Path", 
        nil];
    /* add entry */
    if( entry )
    {
        [launchItems insertObject:entry atIndex:0];
        [dict setObject:launchItems 
                 forKey:@"AutoLaunchedApplicationDictionary"];
    }
    /* update user defaults */
    [userDefs removePersistentDomainForName:loginwindow];
    [userDefs setPersistentDomain:dict forName:loginwindow];
    [userDefs synchronize];
    /* clean up */
    [entry release];
    [launchItems release];
    [dict release];
    [userDefs release];
}

BOOL findOrRemoveLoginItem( NSString* path, BOOL remove ) 
{
    NSString *loginwindow = @"loginwindow";
    NSUserDefaults *userDefs;
    NSMutableDictionary *dict;
    NSMutableArray *launchItems;
    NSEnumerator *enumerator;
    id anObject;
    id theObject = nil;
    
    /* get data from user defaults
        (~/Library/Preferences/loginwindow.plist) */
    userDefs = [[NSUserDefaults alloc] init];
    if( dict = [[userDefs persistentDomainForName:loginwindow] 
                    mutableCopyWithZone:NULL] ) {
        if( launchItems = 
            [[dict objectForKey:@"AutoLaunchedApplicationDictionary"]
                    mutableCopyWithZone:NULL] ) {
            /* remove entry */
            enumerator = [launchItems objectEnumerator];
            while (anObject = [enumerator nextObject]) {
                if ([[anObject objectForKey:@"Path"] isEqualToString:path]) {
                    if (!remove) {
                        [dict release];
                        [userDefs release];
                        [launchItems release];
                        return YES;
                    }
                    theObject = anObject;
                }
            }
            if (!remove && !theObject)
                goto done;
            [launchItems removeObject:theObject];
            [dict setObject:launchItems forKey:@"AutoLaunchedApplicationDictionary"];
            [userDefs removePersistentDomainForName:loginwindow];
            [userDefs setPersistentDomain:dict forName:loginwindow];
            [userDefs synchronize];
done:
            [launchItems release];
        }
        /* clean up */
        [dict release];
        [userDefs release];
    }
    return NO;
}

BOOL isLoginItem( NSString *path )
{
    return findOrRemoveLoginItem( path, NO );
}

void removeLoginItem( NSString *path )
{
    findOrRemoveLoginItem( path, YES );
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
    [mAutolaunch setState:isLoginItem( mFMNPath )];
}

// This is called when it's unselected
- (NSPreferencePaneUnselectReply)shouldUnselect
{
    if ([mAutolaunch state]) {
        if (!isLoginItem( mFMNPath )) {
            addToLoginItems( mFMNPath, YES );
        }
    } else {
        removeLoginItem( mFMNPath );
    }
    [mControls setHidden:YES];
    return NSUnselectNow;
}

- (id) initWithBundle:(NSBundle *)bundle
{
    if ((self = [super initWithBundle:bundle]) == nil) {
        return nil;
    }
    myBundle = [bundle retain];
    mFMNPath = [[myBundle pathForResource:@"FMN" ofType:@"app"] retain];
    return self;
}

- (NSString *)mainNibName
{
    return @"FMNPrefPane";
}

@end
