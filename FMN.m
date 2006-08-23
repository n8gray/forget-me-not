//
//  FMN.m
//  FMN
//
//  Created by David Noblet on 7/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>
#import "FMN.h"
#import "FMNModule.h"
#import "FMNRestorable.h"
#import "CGDisplayConfiguration.h"
#import "FMNModuleLoader.h"

//#import "X11Bridge.h"
//#import "FMNAXModule.h"


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

- (void) handlePreDisplayConfigurationChange
{
    NSLog(@"******** Screen configuration about to be changed! ********");
    NSDate *startDate = [NSDate date];
    
    // Save the current restorables
    NSMutableArray *restorables = [NSMutableArray arrayWithCapacity:20];    
    NSEnumerator* enumerator = [fmnModules objectEnumerator];
    FMNModuleRef module;
    while (module = [enumerator nextObject]) {
        @try {
            //NSDate *restorableDate = [NSDate date];
            NSArray *tmpRestorables = [module getRestorables];
            //NSLog(@"Got %d restorables in %f seconds", [tmpRestorables count],
            //      -[restorableDate timeIntervalSinceNow]);
            [restorables addObjectsFromArray:tmpRestorables];
        }
        @catch (NSException* ex) {
            NSLog([ex reason]);
        }
    }
    
    [screenConfigurations setObject:restorables
                             forKey:currentDisplayConfiguration];
    NSLog(@"Saved %d restorables in %f seconds", [restorables count],
          -[startDate timeIntervalSinceNow]);    
}

- (void) handlePostDisplayConfigurationChange
{
    NSLog(@"======== Screen configuration changed! ========");
    NSDate *startDate = [NSDate date];
    
    [currentDisplayConfiguration release];
    
    // Get the new display configuration
    currentDisplayConfiguration = 
        [[CGDisplayConfiguration configWithCurrent] retain];
    
    // Try to retrieve the restorables associated with the new config
    NSArray* restorables = 
        [screenConfigurations objectForKey : currentDisplayConfiguration];
    
    if (!restorables)
    {
        NSLog(@"Encountered a new display configuration: %@", 
            currentDisplayConfiguration);
        return;
    }
    
    NSEnumerator* enumerator = [restorables objectEnumerator];
    FMNRestorableRef restorable;
    while (restorable = [enumerator nextObject])
    {
        @try
        {
            [restorable restore];
        }
        @catch (NSException* ex)
        {
            NSLog([ex reason]);
        }
    }
    
    NSLog(@"Restored %d restorables in %f seconds for configuration: %@",
          [restorables count], -[startDate timeIntervalSinceNow], 
          currentDisplayConfiguration);
}

- (BOOL) activateFMN
{
    // Register to be notified when the screen configuration changes
    NSLog(@"Activating");
    [self registerScreenChangeNotificationHandler];
    isActive = YES;
    return YES;
}
    
- (BOOL) deactivateFMN
{
    // Unregister the screen change handler
    NSLog(@"Deactivating");
    [self unregisterScreenChangeNotificationHandler];
    isActive = NO;
    return YES;
}

- (BOOL) isActiveFMN
{
    return isActive;
}

- (void) quitFMN
{
    NSLog(@"Quitting");
    [[NSApplication sharedApplication] terminate:self];
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
    
    // Set up the modules.
    NSBundle *mainBundle = [NSBundle mainBundle];
    fmnModules = 
        [[FMNModuleLoader allPluginsOfBundle:mainBundle 
                                withProtocol:@protocol(FMNModule)] retain];
    
    [self activateFMN];
    
    return self;
}

- (BOOL) registerAsServer
{
    serverConnection = [NSConnection defaultConnection];
    [serverConnection setRootObject:self];
    return [serverConnection registerName:@"org.metaprl.ForgetMeNot"];
}

- (void) awakeFromNib
{
    NSLog(@"Awake!");
    if (![self registerAsServer])
        NSLog(@"Couldn't register as a distributed object server!");
}

- (void) dealloc
{
    [self deactivateFMN];
    
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

