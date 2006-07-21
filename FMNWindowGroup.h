//
//  FMNWindowGroup.h
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNWindow.h"
#import "FMNWindowOrientation.h"

//NSString* FMNWindowGroupException = @"FMNWindowGroupException";
#define FMNWindowGroupException @"FMNWindowGroupException"

@protocol FMNWindowGroup 

- (NSSet*) getWindows;
- (NSSet*) getCurrentWindowOrientations;

@end

typedef id<NSObject,FMNWindowGroup> FMNWindowGroupRef;
