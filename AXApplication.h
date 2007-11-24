//
//  AXApplication.h
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "FMNWindowGroup.h"

@interface AXApplication : NSObject<FMNWindowGroup,NSCoding> {
    @protected AXUIElementRef appElement;
    @protected ProcessSerialNumber psn;
    @protected pid_t pid;
    @protected NSString *appName;
    @protected NSPoint origin;
}

+ (id) configWithPSN : (ProcessSerialNumber) processSerialNumber
             appName : (NSString *)name
              origin : (NSPoint)origin;
- (id) initWithPSN : (ProcessSerialNumber) processSerialNumber
           appName : (NSString *)name
            origin : (NSPoint)origin;
- (NSString *)name;

@end
