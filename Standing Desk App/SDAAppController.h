//
//  SDAAppController.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAAppSettings.h"

@interface SDAAppController : NSObject

/* Settings for the Standing Desk App  */
@property (strong) SDAAppSettings* settings;

/* Saves the current settings to disk */
-(void)saveSettings;

/* Reloads the settings from disk */
-(void)loadSettings;
@end
