//
//  X11Bridge.h
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
// This is to prevent a collision between X11's Cursor and Quicktime's
#define Cursor X11Cursor
#import <X11/Xlib.h>
#import <X11/Xatom.h>
#import <X11/Xutil.h>
#undef Cursor


@interface X11Bridge : NSObject {
    NSString *mDisplayName;
    Display *mDisplay;
    Window mRoot;
}

- (NSMutableSet *) getWindowOrientationsSet;

- (void) setDisplayName:(NSString *)name;
- (Display *) display;
- (BOOL) openDisplay;
- (int) closeDisplay;

@end
