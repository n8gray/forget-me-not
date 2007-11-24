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
             appName : (NSString *)name
{
    return [[[AXApplication alloc] initWithPSN : processSerialNumber
                                       appName : name] 
        autorelease];
}

- (NSString *) description
{
    return [NSString stringWithString:appName];
}

- (id) init { [self release]; return nil; }

- (id) initWithPSN : (ProcessSerialNumber) processSerialNumber
             appName : (NSString *)name
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
    
    appName = [name retain];
    return self;
}

- (NSArray*) getWindows
{    
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
    NSMutableArray* windows = 
        [NSMutableArray arrayWithCapacity : [windowArray count]];
    
    NSEnumerator* enumerator = [windowArray objectEnumerator];
    AXUIElementRef elt;
    while (elt = (AXUIElementRef)[enumerator nextObject]) {
        [windows addObject:
            [[[AXWindow alloc] initWithAXElement:elt ofApp:self] autorelease]];
    }
    
    [windowArray release];
    
    return windows;
}

- (NSArray*) getCurrentWindowOrientations
{
    NSArray* windows = [self getWindows];
    NSMutableArray* windowOrientations = 
        [NSMutableArray arrayWithCapacity : [windows count]];
    
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
    if (appName)
    {
        [appName release];
    }

    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:appName forKey:@"AXAappName"];
    [encoder encodeBytes:(const uint8_t*)&appElement 
                  length:sizeof(AXUIElementRef) 
                  forKey:@"AXAappElement"];
    [encoder encodeInt64:(int64_t)pid forKey:@"AXApid"];
    [encoder encodeBytes:(const uint8_t*)&psn
                  length:sizeof(ProcessSerialNumber) 
                  forKey:@"AXApsn"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned dummy;
    self = [super init];
    appName = [[decoder decodeObjectForKey:@"AXAappName"] retain];
    appElement = *(AXUIElementRef *)[decoder decodeBytesForKey:@"AXAappElement"
                                             returnedLength:&dummy];
    pid = (pid_t)[decoder decodeInt64ForKey:@"AXApid"];
    psn = *(ProcessSerialNumber *)[decoder decodeBytesForKey:@"AXApsn"
                                              returnedLength:&dummy];
    return self;
}

- (NSString *)name
{
    return appName;
}

@end
