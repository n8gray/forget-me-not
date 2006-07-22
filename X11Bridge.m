//
//  X11Bridge.m
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "X11Bridge.h"
#import "X11WindowOrientation.h"
#import <X11/Xmu/WinUtil.h>     /* For XmuClientWindow */

@implementation X11Bridge

- (id) init
{
    char *dispName;
    self = [super init];
    if (!self)
        return self;
    
    /* XXX: We should make this a preferences item */
    if (!(dispName = getenv("DISPLAY")))
        dispName = ":0";
    
    mDisplayName = [[NSString stringWithCString:dispName] retain];
    return self;
}

- (void) setDisplayName:(NSString *)name
{
    NSString *tmp = [name retain]; 
    if (mDisplayName)
        [mDisplayName release];
    mDisplayName = tmp;
}
    
- (NSMutableSet *) getWindowOrientationsSet
{
    Window wDummy, *children;
    unsigned int nChildren;
    NSMutableSet *set = nil;
    
    if (![self openDisplay])
        return nil;
    
    mRoot = DefaultRootWindow(mDisplay);
    if (XQueryTree( mDisplay, mRoot, &wDummy, &wDummy, &children, &nChildren )) {
        set = [[NSMutableSet alloc] init];
        int i;
        for (i=0; i<nChildren; ++i) {
            Window wClient = XmuClientWindow( mDisplay, children[i] );
            if( wClient == children[i] ) {
                //NSLog(@"No client window found for X11 window 0x%x\n", wClient);
                continue;
            }
            X11WindowOrientation *xwo = 
                    [[X11WindowOrientation alloc] 
                        initWithXWindow:wClient withBridge:self];
            if (xwo == nil) {
                NSLog(@"Couldn't make X11WindowOrientation for X Window 0x%x\n", wClient);
                continue;
            }
            [set addObject:xwo];
        }
        if (nChildren) {
            XFree(children);
        }
    } else {
        NSLog(@"XQueryTree Failed!");
    }
    [self closeDisplay];
    NSLog(@"Retrieved orientations for %i X11 windows", [set count]);
    return set;
}

- (Display *) display { return mDisplay; };

- (BOOL) openDisplay {
    mDisplay = XOpenDisplay([mDisplayName cString]);
    if (!mDisplay) {
        NSLog (@"Couldn't open X11 display %@", mDisplayName);
        return NO;
    }
    return YES;
}

- (int) closeDisplay {
    int i = XCloseDisplay(mDisplay);
    mDisplay = NULL;
    return i;
}

@end
