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

- (NSSet*) getCurrentWindowOrientationSet
{
    NSArray* launchedApplications = 
        [[NSWorkspace sharedWorkspace] launchedApplications];
    
    NSEnumerator* enumerator = [launchedApplications objectEnumerator];
    NSMutableSet* orientations = [NSMutableSet setWithCapacity : 100];
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
            [orientations unionSet : [app getCurrentWindowOrientations]];
        }
        @catch (NSException* ex)
        {
            NSLog([ex reason]);
        }
    }
    
    return orientations;
}

- (void) handlePreDisplayConfigurationChange
{
    NSLog(@"Screen configuration about to be changed!");
    
    // Capture the current orientation of the windows
    [screenConfigurations setObject : [self getCurrentWindowOrientationSet] 
        forKey : currentDisplayConfiguration];
}

- (void) handlePostDisplayConfigurationChange
{
    NSLog(@"Screen configuration changed!");
    
    //[currentDisplayConfiguration release];
    
    // Get the new display configuration
    currentDisplayConfiguration = 
        [[CGDisplayConfiguration configWithCurrent] retain];
    
    // Try to retrieve the window orientation set associated with the new config
    NSSet* windowOrientationSet = 
        [screenConfigurations objectForKey : currentDisplayConfiguration];
    
    if (!windowOrientationSet)
    {
        NSLog(@"Encountered a new display configuration: %@", 
            currentDisplayConfiguration);
        return;
    }
    
    NSLog(@"Restoring the orientation of %d windows for configuration: %@",
        [windowOrientationSet count], currentDisplayConfiguration);
    
    NSEnumerator* enumerator = [windowOrientationSet objectEnumerator];
    FMNWindowOrientation* windowOrientation;
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
    
    if(flags == kCGDisplayBeginConfigurationFlag)
    {
        [fmn handlePreDisplayConfigurationChange];
    }
    else
    {
        [fmn handlePostDisplayConfigurationChange];
    }
}

