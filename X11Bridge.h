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
#import <X11/Xmu/WinUtil.h>     /* For XmuClientWindow */
#undef Cursor

#import "FMNModule.h"


@interface X11Bridge : NSObject <FMNModule,NSCoding> {
    NSString *mDisplayName;
    Display *mDisplay;
}

/* Designated initializer */
- (id) initWithDisplayName:(NSString *)dispName;

- (NSMutableArray *) getRestorables;

- (void) setDisplayName:(NSString *)name;
- (Display *) display;
- (BOOL) openDisplay;
- (int) closeDisplay;

@end
