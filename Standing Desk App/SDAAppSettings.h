//
//  SDAAppSettings.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAAlertSetting.h"

#define SDA_DEFAULT_STAND_INTERVAL  30
#define SDA_DEFAULT_SIT_INTERVAL    30
#define SDA_DEFAULT_IDLE_TIME       10

/*
    Represents application user configuration settings for
 Standing Desk App.
*/
@interface SDAAppSettings : NSObject

/* Default state of the application: (Standing/Sitting) */
@property (copy) NSString* defaultState;

/* Time, in minutes, of standing state */
@property int standingInterval;

/* Time, in sittings, of sitting state */
@property int sittingInterval;

/* Amount of time to allow machine idling prior to pausing timer. */
@property int idlePauseTime;

/* Settings for Stand Alerts */
@property (strong) SDAAlertSetting* standingSettings;

/* Settings for Sit Alerts */
@property (strong) SDAAlertSetting* sittingSettings;

/* Transform settings to dictionary */
-(NSDictionary*)toDictionary;

/* Load settings from the specified file path */
+(SDAAppSettings*)settingsFromFile:(NSString*)filePath;
@end
