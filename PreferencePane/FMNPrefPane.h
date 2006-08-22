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
}

//- (void) mainViewDidLoad;
- (IBAction) toggleActivated:(id)sender;
- (NSString *)mainNibName;


@end
