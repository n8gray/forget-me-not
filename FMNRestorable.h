/*
 *  FMNRestorable.h
 *  FMN
 *
 *  Created by Nathaniel Gray on 8/16/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

enum
{
    kRestorableDefaultPriority = 0
};

/* 
 * This protocol represents the class of objects that can be restored after 
 * a display configuration change.
 */
@protocol FMNRestorable

- (void) restoreWithContext : (NSDictionary*) context;
- (int) priority;

@end

typedef id<NSObject,FMNRestorable> FMNRestorableRef;
