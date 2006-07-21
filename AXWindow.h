//
//  AXWindow.h
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNWindow.h"

@interface AXWindow : NSObject <FMNWindow> {
    AXUIElementRef windowElement;
}

- (id) initWithAXElement : (AXUIElementRef) windowElem;

@end
