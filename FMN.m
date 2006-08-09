//
//  FMN.m
//  FMN
//
//  Created by David Noblet on 7/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>
#import "FMN.h"
#import "AXApplication.h"
#import "CGDisplayConfiguration.h"


static void FMN_CGDisplayReconfigurationCallback (
        CGDirectDisplayID display,
        CGDisplayChangeSummaryFlags flags,
        void* userInfo
    );

@implementation FMN

- (void) registerScreenChangeNotificationHandler
{
    CGDisplayRegisterReconfigurationCallback(
        FMN_CGDisplayReconfigurationCallback, self);
}

- (void) unregisterScreenChangeNotificationHandler
{
    CGDisplayRemoveReconfigurationCallback(
        FMN_CGDisplayReconfigurationCallback,self);
}

- (NSArray*) getCurrentWindowOrientations
{
    NSArray* launchedApplications = 
        [[NSWorkspace sharedWorkspace] launchedApplications];
    
    NSEnumerator* enumerator = [launchedApplications objectEnumerator];
    NSMutableArray* orientations = [NSMutableArray arrayWithCapacity : 100];
    ProcessSerialNumber psn;
    NSDictionary* appInfo;
    while (appInfo = [enumerator nextObject])
    {
        NSNumber* tmp;
        tmp = [appInfo objectForKey:@"NSApplicationProcessSerialNumberLow"];
        psn.lowLongOfPSN = [tmp longValue];
        tmp = [appInfo objectForKey:@"NSApplicationProcessSerialNumberHigh"];
        psn.highLongOfPSN = [tmp longValue];
        
        @try
        {
            AXApplication* app = [AXApplication configWithPSN : psn];
            [orientations addObjectsFromArray : [app getCurrentWindowOrientations]];
        }
        @catch (NSException* ex)
        {
            NSLog([ex reason]);
        }
    }
    
    NSMutableArray *x11orientations = [x11Bridge getWindowOrientations];
    if (x11orientations != nil)
        [orientations addObjectsFromArray : x11orientations];
    
    return orientations;
}

- (void) handlePreDisplayConfigurationChange
{
    NSLog(@"Screen configuration about to be changed!");
    
    // Capture the current orientation of the windows
    [screenConfigurations setObject : [self getCurrentWindowOrientations] 
        forKey : currentDisplayConfiguration];
}

- (void) handlePostDisplayConfigurationChange
{
    NSLog(@"Screen configuration changed!");
    
    //[currentDisplayConfiguration release];
    
    // Get the new display configuration
    currentDisplayConfiguration = 
        [[CGDisplayConfiguration configWithCurrent] retain];
    
    // Try to retrieve the window orientations associated with the new config
    NSArray* windowOrientations = 
        [screenConfigurations objectForKey : currentDisplayConfiguration];
    
    if (!windowOrientations)
    {
        NSLog(@"Encountered a new display configuration: %@", 
            currentDisplayConfiguration);
        return;
    }
    
    NSLog(@"Restoring the orientation of %d windows for configuration: %@",
        [windowOrientations count], currentDisplayConfiguration);
    
    NSEnumerator* enumerator = [windowOrientations objectEnumerator];
    FMNWindowOrientation* windowOrientation;
    BOOL didOpenX11 = [x11Bridge openDisplay];
    while (windowOrientation = [enumerator nextObject])
    {
        @try
        {
            [windowOrientation restore];
        }
        @catch (NSException* ex)
        {
            NSLog([ex reason]);
        }
    }
    if (didOpenX11)
        [x11Bridge closeDisplay];
}

- (id) init
{
    if (![super init])
    {
        return nil;
    }
    
    // Initialize dictionary of screen configurations
    screenConfigurations = [[NSMutableDictionary alloc] init];

    // Initialize the current display configuration
    currentDisplayConfiguration = 
        [[CGDisplayConfiguration configWithCurrent] retain];
    
    // Set up the X11 Bridge
    x11Bridge = [[X11Bridge alloc] init];
        
    // Register to be notified when the screen configuration changes
    [self registerScreenChangeNotificationHandler];
    
    return self;
}

- (void) awakeFromNib
{
    NSLog(@"Awake!");
}

- (void) dealloc
{
    // Unregister the app launch/termination handlers
    [self unregisterScreenChangeNotificationHandler];
    
    // Release the dictionary
    if (screenConfigurations)
    {
        [screenConfigurations release];
    }
    
    // Release the current display configuration
    if (currentDisplayConfiguration)
    {
        [currentDisplayConfiguration release];
    }

    [super dealloc];
}

@end

static void FMN_CGDisplayReconfigurationCallback (
        CGDirectDisplayID display,
        CGDisplayChangeSummaryFlags flags,
        void* userInfo
    )
{
    FMN* fmn = (FMN*) userInfo;

    // Only want to react once, not once per screen
    if (!CGDisplayIsMain(display))
        return;
    
    if(flags == kCGDisplayBeginConfigurationFlag)
    {
        [fmn handlePreDisplayConfigurationChange];
    }
    else
    {
        [fmn handlePostDisplayConfigurationChange];
    }
}

