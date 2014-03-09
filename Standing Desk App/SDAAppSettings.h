//
//  SDAAppSettings.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAConstants.h"
#import "SDAAlertSetting.h"
#import "SDAPresetTable.h"


/**
    Represents application user configuration settings for
 Standing Desk App.
*/
@interface SDAAppSettings : NSObject

/** Indicator that the application is currently set in an initial state and never before run. */
@property BOOL isFirstTimeRunning;

/** Default state of the application: (Standing/Sitting) */
@property (copy) NSString* defaultState;

/** Time, in seconds, of standing state */
@property int standingInterval;

/** Time, in seconds, of sitting state */
@property int sittingInterval;

/** Amount of time, in seconds, to allow machine idling prior to pausing timer. */
@property int idlePauseTime;

/** Amount of time, in seconds, to add to a timer if a user chooses to snooze during a state. */
@property int snoozeTime;

/** Whether the app should register itself as a Login Item for the current user. */
@property bool isLoginItem;

/** Settings for Stand Alerts */
@property (strong) SDAAlertSetting* standingSettings;

/** Settings for Sit Alerts */
@property (strong) SDAAlertSetting* sittingSettings;

/** Preset name currently in use */
@property (strong) NSString* currentPreset;

@property (strong) SDAPresetTable *presetTable;

/** Transform settings to dictionary */
-(NSDictionary*)toDictionary;

/** Returns the sitting interval in seconds for the given preset. (-1 if preset doesn't exist) */
-(int)sitIntervalForPreset:(NSString*)presetName;

/** Returns the standing interval in seconds for the given preset. (-1 if preset doesn't exist) */
-(int)standIntervalForPreset:(NSString *)presetName;

/** Load settings from the UserDefaults */
+(SDAAppSettings*)settings;

/** Create default instance of app settings */
+(SDAAppSettings*)defaultSettings;

/** Writes settings to UserDefaults */
-(void)writeSettings;
@end
