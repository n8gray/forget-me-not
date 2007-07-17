//
//  FMNAXModule.m
//  FMN
//
//  Created by Nathaniel Gray on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNAXModule.h"
#import "AXApplication.h"

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
    return self;
}    

- (void) dealloc
{
    if (mExclusions != nil)
        [mExclusions release];
    [super dealloc];
}

typedef int CGSConnection;

extern OSStatus CGSGetWorkspace(const CGSConnection cid, int *workspace);
extern OSStatus CGSSetWorkspace(const CGSConnection cid, int workspace);
extern CGSConnection _CGSDefaultConnection(void);

- (NSArray *) getRestorables
{
    NSMutableArray* orientations = [NSMutableArray arrayWithCapacity : 100];
    int workspace = 0;
    
    CGSConnection cid = _CGSDefaultConnection();
    CGSGetWorkspace(cid,&workspace);

    NSDate *ws_startDate = [NSDate date];
    
    int i;
    for(i=0; i<20; ++i)
    {
        int ws_ret = CGSSetWorkspace(cid,i);
        NSLog (@"Setting workspace: %d (ret=%d)", i, ws_ret);
        
        NSArray* launchedApplications = 
            [[NSWorkspace sharedWorkspace] launchedApplications];
        NSEnumerator* enumerator = [launchedApplications objectEnumerator];
        
        NSDate *startDate = [NSDate date];
        
        ProcessSerialNumber psn;
        NSDictionary* appInfo;
        while (appInfo = [enumerator nextObject])
        {
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
                AXApplication* app = [AXApplication configWithPSN:psn appName:name];
                NSArray *appOrientations = [app getCurrentWindowOrientations];
                [orientations addObjectsFromArray : appOrientations];
                NSLog(@"%@: Got %d windows in %f seconds", name,
                      [appOrientations count], -[startDate timeIntervalSinceNow]);
            }
            @catch (NSException* ex)
            {
                NSLog(@"%@: %@ (after %f seconds)", name, [ex reason],
                      -[startDate timeIntervalSinceNow]);
            }
        }
        
    }
    
    NSLog(@"AX: Got %d windows in %f seconds",
        [orientations count], -[ws_startDate timeIntervalSinceNow]);
    
    CGSSetWorkspace(cid,workspace);
    return orientations;
}
    
@end
