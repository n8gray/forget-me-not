//
//  AXApplication.m
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AXApplication.h"
#import "AXWindow.h"

@implementation AXApplication

+ (id) configWithPSN : (ProcessSerialNumber) processSerialNumber
{
    return [[[AXApplication alloc] initWithPSN : processSerialNumber] 
        autorelease];
}

- (id) init { [self release]; return nil; }

- (id) initWithPSN : (ProcessSerialNumber) processSerialNumber
{
    if(![super init])
        return nil;
    
    psn = processSerialNumber;
    pid = 0;
    GetProcessPID(&psn, &pid);
    
    // Create the accessibility UI element for the given app
    appElement = AXUIElementCreateApplication(pid);
    
    // Create the observer that will receive events
    if (!appElement)
    {
        [self release];
        @throw 
            [NSException
                exceptionWithName : FMNWindowGroupException
                reason : @"Unable to create observer for pid"
                userInfo : nil
            ];
    }
    
    return self;
}

- (NSSet*) getWindows
{
    NSMutableSet* windows = [NSMutableSet setWithCapacity : 10];
    
    CFTypeRef value;
    if (AXUIElementCopyAttributeValue(appElement,kAXWindowsAttribute,
        &value) != kAXErrorSuccess)
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable get AX windows for app"
                userInfo : nil
            ];
    }
    
    NSArray* windowArray = (NSArray*) value;
    
    int i;
    int window_count = [windowArray count];
    for(i=0; i<window_count; ++i)
    {
        FMNWindowRef window = [[[AXWindow alloc] initWithAXElement : 
            (AXUIElementRef)[windowArray objectAtIndex : i]] autorelease];
        [windows addObject : window];
    }
    
    [windowArray release];
    
    return windows;
}

- (NSSet*) getCurrentWindowOrientations
{
    NSSet* windows = [self getWindows];
    NSMutableSet* windowOrientations = 
        [NSMutableSet setWithCapacity : [windows count]];
    
    NSEnumerator* enumerator = [windows objectEnumerator];
    FMNWindowRef window;
    FMNWindowOrientation* windowOrientation;
    //NSLog(@"Getting window orientations");
    while(window = (FMNWindowRef)[enumerator nextObject])
    {
        @try
        {
            windowOrientation = [[[FMNWindowOrientation alloc] 
                initWithWindow : window] autorelease];
            [windowOrientations addObject : windowOrientation];
        }
        @catch (NSException* ex)
        {
            NSLog(@"Error getting window orientation %@", [ex reason]);
        }
    }
    
    return windowOrientations;
}

- (void) dealloc
{
    if (appElement)
    {
        CFRelease(appElement);
    }

    [super dealloc];
}

@end
