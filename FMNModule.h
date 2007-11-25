/*
 *  FMNModule.h
 *  FMN
 *
 *  Created by Nathaniel Gray on 8/16/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */
#import <Cocoa/Cocoa.h>

/*
 * This protocol represents objects that can provide restorables.  
 * getRestorables will be called when a display change is about to occur, and
 * those restorables will have restore called when the current display
 * configuration is once again active.
 */
@protocol FMNModule

- (NSArray *) getRestorables;

/* Called when the restore operation has finished */
- (void) restoreFinished;

@end

typedef id<NSObject,FMNModule> FMNModuleRef;
