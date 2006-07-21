//
//  FMNDisplay.h
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//NSString* FMNDisplayException = @"FMNDisplayException";
#define FMNDisplayException @"FMNDisplayException"

@protocol FMNDisplay

- (NSRect) getDisplayOrientation;

@end

typedef id<NSObject,FMNDisplay> FMNDisplayRef;
