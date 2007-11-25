//
//  FMNAXModule.m
//  FMN
//
//  Created by Nathaniel Gray on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNAXModule.h"
#import "AXApplication.h"

#define MAX_WORKSPACE 16

@implementation FMNAXModule

- (void) setExclusions:(NSArray *)ex
{
    if (mExclusions != nil) {
        [mExclusions release];
    }
    mExclusions = [ex retain];
}

- (id) initWithBundle:(NSBundle *)bundle
{
    self = [super init];
    if (!self)
        return nil;
    // This should be in the prefs pane, but for now put it in the info.plist
    NSArray *exclusions = 
        [bundle objectForInfoDictionaryKey:@"ExcludedAppBundleIDs"];
    if (exclusions == nil) {
        NSLog(@"No excluded apps found");
    } else if (![exclusions isKindOfClass:[NSArray class]]) {
        NSLog(@"Ignoring ExcludedAppBundleIDs.  Not an NSArray! (class = %@)",
              [exclusions class]);
    } else {
        NSLog(@"Excluding apps:\n%@", exclusions);
        mExclusions = [exclusions retain];
    }
    mOrigin = [[AXOrigin alloc] init];
    
    // Yes, this hideous script is the best I could do...
    mCountWSScript = [[NSAppleScript alloc] initWithSource:@"\n\
                      tell application \"System Events\"\n\
                        if spaces enabled of spaces preferences of expose preferences is true then\n\
                          return (spaces rows of spaces preferences of expose preferences) * (spaces columns of spaces preferences of expose preferences)\n\
                        else\n\
                          return 1\n\
                        end if\n\
                      end tell"];
    NSDictionary *err;
    if (![mCountWSScript compileAndReturnError:&err]) {
        NSLog(@"Couldn't compile script to count workspaces.  Using default count.");
        [mCountWSScript release];
        mCountWSScript = nil;
    }
    return self;
}    

- (void) dealloc
{
    if (mExclusions != nil)
        [mExclusions release];
    [mOrigin release];
    [super dealloc];
}

typedef int CGSConnection;

extern OSStatus CGSGetWorkspace(const CGSConnection cid, int *workspace);
extern OSStatus CGSSetWorkspace(const CGSConnection cid, int workspace);
extern CGSConnection _CGSDefaultConnection(void);

- (int) countWorkspaces
{
    if (mCountWSScript) {
        NSDictionary *err;
        NSAppleEventDescriptor *rval;
        rval = [mCountWSScript executeAndReturnError:&err];
        if (nil == rval) {
            NSLog(@"Error executing our workspace counting script.");
        } else {
            int nws = [rval int32Value];
            if (nws > MAX_WORKSPACE){
                NSLog(@"Bogus return value from ws counting script: %i", nws);
            } else {
                return nws;
            }
        }
    }
    return MAX_WORKSPACE;
}

- (NSArray *) getRestorables
{
    NSMutableArray* orientations = [NSMutableArray arrayWithCapacity : 100];
    int workspace = 0;
    
    CGSConnection cid = _CGSDefaultConnection();
    CGSGetWorkspace(cid,&workspace);

    NSDate *ws_startDate = [NSDate date];
    NSPoint origin = [mOrigin getOrigin];
    
    // Get the list of launched applications
    NSArray* launchedApplications = [[NSWorkspace sharedWorkspace] launchedApplications];
    NSEnumerator* enumerator = [launchedApplications objectEnumerator];
    
    // Make an AXApplication for each one
    NSMutableArray *axApps = 
            [NSMutableArray arrayWithCapacity:[launchedApplications count]];
    ProcessSerialNumber psn;
    NSDictionary* appInfo;
    while (appInfo = [enumerator nextObject])
    {
        NSDate *startDate = [NSDate date];
        NSNumber* tmp;
        tmp = [appInfo objectForKey:@"NSApplicationProcessSerialNumberLow"];
        psn.lowLongOfPSN = [tmp longValue];
        tmp = [appInfo objectForKey:@"NSApplicationProcessSerialNumberHigh"];
        psn.highLongOfPSN = [tmp longValue];
        NSString *name = [appInfo objectForKey:@"NSApplicationName"];
        NSString *bundleID = [appInfo objectForKey:@"NSApplicationBundleIdentifier"];
        if (mExclusions != nil && [mExclusions containsObject:bundleID]) {
            NSLog (@"Skipping excluded app: \"%@\" (%@)", name, bundleID);
            continue;
        }
        
        @try
        {
            AXApplication* app = [AXApplication configWithPSN:psn 
                                                      appName:name
                                                       origin:origin];
            [axApps addObject:app];
        }
        @catch (NSException* ex)
        {
            NSLog(@"%@: %@ (after %f seconds)", name, [ex reason],
                  -[startDate timeIntervalSinceNow]);
        }
    }
    
    int i;
    for(i=1; i<=[self countWorkspaces]; ++i)
    {
        int ws_ret = CGSSetWorkspace(cid,i);
        int wsWinCount = 0;
        NSLog (@"Setting workspace: %d (ret=%d)", i, ws_ret);
        AXApplication *app;
        enumerator = [axApps objectEnumerator];
        while (app = [enumerator nextObject]) {
            NSDate *startDate = [NSDate date];
            @try
            {
                NSArray *appOrientations = [app getCurrentWindowOrientations];
                int nWins = [appOrientations count];
                wsWinCount += nWins;
                if (nWins > 0) {
                    [orientations addObjectsFromArray : appOrientations];
                    NSLog(@"%@: Got %d windows in %.2f seconds", [app name],
                          nWins, -[startDate timeIntervalSinceNow]);
                }
            }
            @catch (NSException* ex)
            {
                NSLog(@"%@: %@ (after %f seconds)", [app name], [ex reason],
                      -[startDate timeIntervalSinceNow]);
            }
            
        }
        
    }
    
    NSLog(@"AX: Got %d windows in %f seconds",
        [orientations count], -[ws_startDate timeIntervalSinceNow]);
    
    CGSSetWorkspace(cid,workspace);
    return orientations;
}

- (void) restoreFinished
{
    [mOrigin resetOrigin];
}
@end
