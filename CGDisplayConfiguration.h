//
//  CGDisplayConfiguration.h
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNDisplayConfiguration.h"

#define CG_MAX_DISPLAYS 128

@interface CGDisplayConfiguration : NSObject<NSCopying,FMNDisplayConfiguration> {
    @protected NSMutableArray* displays;
}

@end
