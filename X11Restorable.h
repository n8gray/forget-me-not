//
//  X11Restorable.h
//  FMN
//
//  Created by Nathaniel Gray on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNRestorable.h"
#import "X11Bridge.h"

/* This class wraps all X11 windows in a single restorable so that the display
   can be opened and closed properly */
@interface X11Restorable : NSObject <FMNRestorable> {
    NSMutableArray *mWindows;
    X11Bridge *mX11Bridge;
}

- (id) initWithBridge:(X11Bridge *) bridge;

@end
