//
//  FMNScreenConfiguration.h
//  FMN
//
//  Created by David Noblet on 7/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNDisplay.h"

@protocol FMNDisplayConfiguration

+ (id<NSObject,NSCopying,FMNDisplayConfiguration>) configWithCurrent;

- (unsigned) getDisplayCount;
- (FMNDisplayRef) getMainDisplay;
- (FMNDisplayRef) getDisplay : (unsigned) i;

- (NSString*) description;

@end

typedef id<NSObject,NSCopying,FMNDisplayConfiguration> 
    FMNDisplayConfigurationRef;
