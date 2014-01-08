//
//  SDAAppSettings.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAAlertSetting.h"

#define SDA_DEFAULT_STAND_INTERVAL  1800 // 30 minutes
#define SDA_DEFAULT_SIT_INTERVAL    1800 // 30 minutes
#define SDA_DEFAULT_IDLE_TIME       600  // 10 minutes
#define SDA_DEFAULT_SNOOZE_TIME     300  // 5 minutes

/*
    Represents application user configuration settings for
 Standing Desk App.
*/
@interface SDAAppSettings : NSObject

/* Default state of the application: (Standing/Sitting) */
@property (copy) NSString* defaultState;

/* Time, in seconds, of standing state */
@property int standingInterval;

/* Time, in seconds, of sitting state */
@property int sittingInterval;

/* Amount of time, in seconds, to allow machine idling prior to pausing timer. */
@property int idlePauseTime;

/* Amount of time, in seconds, to add to a timer if a user chooses to snooze during a state. */
@property int snoozeTime;

/* Whether the app should register itself as a Login Item for the current user. */
@property bool isLoginItem;

/* Settings for Stand Alerts */
@property (strong) SDAAlertSetting* standingSettings;

/* Settings for Sit Alerts */
@property (strong) SDAAlertSetting* sittingSettings;

/* Transform settings to dictionary */
-(NSDictionary*)toDictionary;

/* Load settings from the specified file path */
+(SDAAppSettings*)settingsFromFile:(NSString*)filePath;

/* Create default instance of app settings */
+(SDAAppSettings*)defaultSettings;
@end
