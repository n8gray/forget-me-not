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
    NSMutableSet *restorables = [NSMutableSet setWithCapacity:20];
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

int restorableCompare(id a, id b, void* c)
{
    FMNRestorableRef r1 = (FMNRestorableRef)a;
    FMNRestorableRef r2 = (FMNRestorableRef)b;
    
    int p1 = [r1 priority];
    int p2 = [r2 priority];
    
    if(p1 > p2)
    {
        return NSOrderedAscending;
    }
    else if (p1 == p2)
    {
        return NSOrderedSame;
    }
    
    return NSOrderedDescending;
}

- (NSDictionary*) getRestorationContext : (FMNDisplayConfigurationRef) previousDisplayConfiguration
{
    NSMutableDictionary* context = 
        [NSMutableDictionary dictionaryWithCapacity:10];
        
    NSRect prev = [[previousDisplayConfiguration getMainDisplay] getDisplayOrientation];
    NSRect curr = [[currentDisplayConfiguration getMainDisplay] getDisplayOrientation];
    
    NSNumber* off_x = [NSNumber numberWithFloat:(prev.origin.x - curr.origin.x)];
    NSNumber* off_y = [NSNumber numberWithFloat:(prev.origin.y - curr.origin.y)];
    
    [context setObject:off_x forKey:@"com.fmn.x-coordinate-offset"];
    [context setObject:off_y forKey:@"com.fmn.y-coordinate-offset"];
    
    return context;
}

- (void) handlePostDisplayConfigurationChange
{
    NSLog(@"======== Screen configuration changed! ========");
    NSDate *startDate = [NSDate date];
    FMNDisplayConfigurationRef previousDisplayConfiguration = 
        currentDisplayConfiguration;
    
    // Get the new display configuration
    currentDisplayConfiguration = 
        [[CGDisplayConfiguration configWithCurrent] retain];
        
    NSDictionary* restorationContext = 
        [self getRestorationContext : previousDisplayConfiguration];
    
    // Try to retrieve the restorables associated with the new config
    NSMutableSet* restorableSet = 
        [screenConfigurations objectForKey : currentDisplayConfiguration];
    
    if (!restorableSet)
    {
        NSLog(@"Encountered a new display configuration: %@", 
            currentDisplayConfiguration);
        return;
    }
    
    NSMutableArray* restorables = [NSMutableArray arrayWithCapacity:[restorableSet count]];
    NSEnumerator* set = [restorableSet objectEnumerator];

    FMNRestorableRef restorable;    
    while(restorable = [set nextObject])
    {
        [restorables addObject:restorable];
    }
    
    // Sort the restorables, according to priority
    [restorables sortUsingFunction:restorableCompare context:nil];
    
    NSEnumerator* enumerator = [restorables objectEnumerator];

    while (restorable = [enumerator nextObject])
    {
        @try
        {
            [restorable restoreWithContext : restorationContext];
        }
        @catch (NSException* ex)
        {
            NSLog([ex reason]);
        }
    }
    
    NSLog(@"Restored %d restorables in %f seconds for configuration: %@",
          [restorables count], -[startDate timeIntervalSinceNow], 
          currentDisplayConfiguration);
    /* May want to remove the restorables from screenConfigurations at this
        point -- it's just going to be discarded at the next config change */
    [previousDisplayConfiguration release];
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
    
    if (fmnModules)
        [fmnModules release];
    if (serverConnection)
        [serverConnection release];

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

