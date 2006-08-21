//
//  X11Restorable.m
//  FMN
//
//  Created by Nathaniel Gray on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "X11Restorable.h"
#import "X11WindowOrientation.h"

@implementation X11Restorable

- (id) initWithBridge:(X11Bridge *) bridge
{
    self = [super init];
    if (!self) {
        return nil;
    }

    Window wDummy, *children;
    unsigned int nChildren;
    mWindows = nil;
    
    mX11Bridge = [bridge retain]; 
    if (![bridge openDisplay])
        return nil;
    Display *disp = [bridge display];
    NSDate *startDate = [NSDate date];
    
    Window root = DefaultRootWindow(disp);
    if (XQueryTree( disp, root, &wDummy, &wDummy, &children, &nChildren )) {
        mWindows = [[NSMutableArray alloc] init];
        int i;
        for (i=0; i<nChildren; ++i) {
            Window wClient = XmuClientWindow( disp, children[i] );
            if( wClient == children[i] ) {
                //NSLog(@"No client window found for X11 window 0x%x\n", wClient);
                continue;
            }
            X11WindowOrientation *xwo = 
                [[X11WindowOrientation alloc] 
                        initWithXWindow:wClient onDisplay:disp];
            if (xwo == nil) {
                NSLog(@"Couldn't make X11WindowOrientation for X Window 0x%x\n", wClient);
                continue;
            }
            [mWindows addObject:xwo];
        }
        if (nChildren) {
            XFree(children);
        }
    } else {
        NSLog(@"XQueryTree Failed!");
    }
    [bridge closeDisplay];
    NSLog(@"Saved orientations for %i X11 windows in %f seconds", 
          [mWindows count], -[startDate timeIntervalSinceNow]);
    
    return self;
}

- (void) dealloc
{
    if (mX11Bridge)
        [mX11Bridge release];
    if (mWindows)
        [mWindows release];
    [super dealloc];
}

- (void) restore
{
    if ([mX11Bridge openDisplay]) {
        NSDate *startDate = [NSDate date];
        Display *disp = [mX11Bridge display];
        NSEnumerator* enumerator = [mWindows objectEnumerator];
        X11WindowOrientation *window;
        int i = 0;
        while (window = [enumerator nextObject]) {
            @try {
                [window restoreOnDisplay:disp];
                ++i;
            }
            @catch (NSException* ex) {
                NSLog([ex reason]);
            }
        }
        [mX11Bridge closeDisplay];
        NSLog(@"Restored orientations for %i X11 windows in %f seconds", 
              i, -[startDate timeIntervalSinceNow]);
    }
}

@end
