//
//  FMNWindow.h
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define FMNWindowException @"FMNWindowException"

@protocol FMNWindow

- (NSPoint) getWindowPosition;
- (NSSize) getWindowSize;

- (void) setWindowPosition : (NSPoint) pos Context : (NSDictionary*) context;
- (void) setWindowSize : (NSSize) size Context : (NSDictionary*) context;
- (void) setWindowSize : (NSSize) size Position : (NSPoint) pos Context : (NSDictionary*) context;

@end

typedef id<NSObject,NSCoding,FMNWindow> FMNWindowRef;
