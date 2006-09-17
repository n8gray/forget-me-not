//
//  FMNPrefpaneModule.h
//  FMN
//
//  Created by David Noblet on 9/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol FMNPrefpaneModule

- (void) notifyWillSelect;
- (void) notifyDidSelect;
- (void) notifyUnselected;

- (NSView*) getControlView;
- (BOOL) isTabControl;

@end

typedef id<NSObject,FMNPrefpaneModule> FMNPrefpaneModuleRef;
