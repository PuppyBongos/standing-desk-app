//
//  SDAAlert.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDA_ALERT_DEFAULT_VOLUME  1.0f
#define SDA_ALERT_DEFAULT_MUTE    NO

/*
    Represents the user settings for an alert, including which
sound will play during an alert, the volume and whether the
alert is muted or not.
*/
@interface SDAAlertSetting : NSObject

/* Name of the sound file the alert plays */
@property (copy) NSString* soundFile;

/* Volume of the sound to play */
@property float volume;

/* Indices when the mute */
@property BOOL isMute;

/* Transforms this instance to a dictionary of SDAAlertSetting values */
-(NSDictionary*) toDictionary;

/* Transforms a dictionary of SDAAlertSetting values to an instance */
+(SDAAlertSetting*) settingFromDictionary:(NSDictionary*)dict;
@end
