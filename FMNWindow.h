//
//  FMNWindow.h
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//NSString* FMNWindowException = @"FMNWindowException";
#define FMNWindowException @"FMNWindowException"

@protocol FMNWindow

- (NSPoint) getWindowPosition;
- (NSSize) getWindowSize;

- (void) setWindowPosition : (NSPoint) pos;
- (void) setWindowSize : (NSSize) size;

@end

typedef id<NSObject,NSCoding,FMNWindow> FMNWindowRef;