//
//  FMNWindowOrientation.h
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNWindow.h"

@interface FMNWindowOrientation : NSObject {
    @protected NSPoint position;
    @protected NSSize size;
    @protected FMNWindowRef window;
}

- (id) initWithWindow : (FMNWindowRef) win;
- (void) restore;

@end
