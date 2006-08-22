//
//  FMNPrefPane.h
//  FMN
//
//  Created by Nathaniel Gray on 8/1/06.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface FMNPrefPane : NSPreferencePane 
{
    id mFMNProxy;
    NSBundle *myBundle;
    
    IBOutlet NSProgressIndicator *mSpinner;
    IBOutlet NSTextField *mStatusField;
    IBOutlet NSButton *mActivated;
    IBOutlet NSBox *mControls;
    IBOutlet NSButton *mLaunchQuit;
}

- (IBAction) toggleActivated:(id)sender;
- (IBAction) launchOrQuit:(id)sender;

- (NSString *)mainNibName;


@end
