//
//  AXOrigin.h
//  FMN
//
//  Created by Nathaniel Gray on 11/24/07.
//  Copyright 2007 Nathaniel Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AXWindow.h"

@interface AXOrigin : NSObject {
    NSWindow *originWindow;
    AXWindow *originAXWindow;
}
- (NSPoint) getOrigin;
- (void) resetOrigin;

@end
