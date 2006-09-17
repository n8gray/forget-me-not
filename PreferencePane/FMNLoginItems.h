//
//  FMNLoginItems.h
//  FMN
//
//  Created by Nathaniel Gray on 9/6/06.
//  Copyright 2006 Nathaniel Gray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNPrefpaneModule.h"

@interface FMNLoginItems : NSObject<FMNPrefpaneModule> {
    NSString* mFMNPath;
    IBOutlet NSButton* mAutolaunch;
}

// appName is the name of the app *without* any .app extension.
// For example, @"Preview" or @"Finder"
+ (BOOL) isLoginItem:(NSString *)appName;
+ (void) deleteLoginItem:(NSString *)appName;
+ (BOOL) addLoginItem:(NSString *)appPath hidden:(BOOL)hidden;

@end
