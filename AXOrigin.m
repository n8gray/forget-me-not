//
//  AXOrigin.m
//  FMN
//
//  Created by Nathaniel Gray on 11/24/07.
//  Copyright 2007 Nathaniel Gray. All rights reserved.
//

#import "AXOrigin.h"
#import "AXApplication.h"
#import "FMNRestorable.h"

#include <Carbon/Carbon.h>  // For GetCurrentProcess

@implementation AXOrigin

// Make a little invisible window that sits at (0,0) to provide us with a
// reliable origin.
- (void) createOriginWindow
{
    NSPoint origin;
    NSSize small;
    NSRect r;
    origin.x = 0.0; origin.y = 0.0;
    small.width = 10.0; small.height = 10.0;
    r.origin = origin; r.size = small;
    originWindow = [[NSWindow alloc] initWithContentRect:r
                                               styleMask:NSBorderlessWindowMask 
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    [originWindow setCanHide:NO];
    [originWindow setHasShadow:NO];
    //[originWindow setOpaque:NO];
    //[originWindow setAlphaValue:0.0];
    //[originWindow setIgnoresMouseEvents:YES];
    // I'm making this very visible for now so we know it's working
    //[originWindow setBackgroundColor:[NSColor redColor]];
    // XXX: This is only in Leopard -- do we want to try to work around that?
    //[originWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    if ([originWindow respondsToSelector:@selector(setCollectionBehavior:)])
        [originWindow setCollectionBehavior:1];
    [originWindow orderBack:self];
    // Quartz uses bottom-left (mathematical) coordinates, so this is how we
    // put the window at the top-left corner
    size_t height = CGDisplayPixelsHigh(CGMainDisplayID());
    [originWindow setFrameTopLeftPoint:NSMakePoint(0.0, height)];
    
    // We can't get the AXWindow yet.  Do it later.
    originAXWindow = nil;
}

- (id) init
{
    self = [super init];
    if (!self)
        return nil;
    [self createOriginWindow];
    return self;
}

- (void) dealloc
{
    [originWindow release];
    if (originAXWindow)
        [originAXWindow release];
    [super dealloc];
}

- (NSPoint) getOrigin
{
    // XXX: Error checking here!!!
    //NSLog(@"Getting origin...");
    if (originAXWindow == nil) {
        ProcessSerialNumber psn;
        GetCurrentProcess(&psn);
        AXApplication* app = [AXApplication configWithPSN:psn 
                                                  appName:@"Forget-Me-Not"
                                                   origin:NSMakePoint(0.0,0.0)];
        NSArray *appWindows = [app getWindows];
        //NSLog(@"FMN has %d window", [appWindows count]);
        originAXWindow = [[appWindows objectAtIndex:0] retain];
    }
    NSPoint origin = [originAXWindow getWindowPosition];
    NSLog(@"AX: Got origin at (%f, %f)", origin.x, origin.y);
    return origin;
}

- (void) resetOrigin
{
    if (originAXWindow == nil) {
        @throw 
        [NSException
         exceptionWithName : @"NoOriginError"
         reason : @"originAXWindow is nil!"
         userInfo : nil
         ];
    }
    NSLog(@"Resetting Origin");
    // This doesn't work properly!
    [originAXWindow setWindowPosition:NSMakePoint(0.0,0.0)];
    // Try the quartz way again.
    //size_t height = CGDisplayPixelsHigh(CGMainDisplayID());
    //[originWindow setFrameTopLeftPoint:NSMakePoint(0.0, height)];
    NSPoint origin = [self getOrigin];
    NSLog(@"Origin is now reset to (%f,%f)", origin.x, origin.y);    
}

@end
