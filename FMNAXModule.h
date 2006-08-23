//
//  FMNAXModule.h
//  FMN
//
//  Created by Nathaniel Gray on 8/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNModule.h"

@interface FMNAXModule : NSObject <FMNModule> {
    NSArray *mExclusions;
}
- (void) setExclusions:(NSArray *)ex;
- (id) initWithBundle:(NSBundle *)bundle;
@end
