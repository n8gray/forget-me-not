//
//  CGDisplay.h
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNDisplay.h"

@interface CGDisplay : NSObject <FMNDisplay,NSCoding> {
    @protected CGDirectDisplayID displayID;
    @protected NSRect orientation;
}

- (id) initWithDisplayID: (CGDirectDisplayID) did;

@end
