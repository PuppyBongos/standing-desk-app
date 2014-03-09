//
//  SDA_Constants.h
//  Standing Desk App
//
//  Created by David Vera on 3/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#ifndef Standing_Desk_App_SDA_Constants_h
#define Standing_Desk_App_SDA_Constants_h

#define SDA_DEFAULT_FIRST_TIME      YES
#define SDA_DEFAULT_STAND_INTERVAL  1800 // 30 minutes
#define SDA_DEFAULT_SIT_INTERVAL    1800 // 30 minutes
#define SDA_DEFAULT_IDLE_TIME       600  // 10 minutes
#define SDA_DEFAULT_SNOOZE_TIME     300  // 5 minutes
#define SDA_DEFAULT_PRESET          @"Custom"

#define UD_PRESET           @"Preset"
#define UD_LOGIN            @"LoginItemStatus"
#define UD_FIRST_TIME       @"FirstTimeRunning"
#define UD_STAND_INTERVAL   @"StandStateInterval"
#define UD_SIT_INTERVAL     @"SitStateInterval"
#define UD_IDLE_TIME        @"IdlePauseTime"
#define UD_SNOOZE_TIME      @"SnoozeTime"

#define UD_STAND_ALERT      @"StandAlert"
#define UD_SIT_ALERT        @"SitAlert"

#define SDA_CONFIG_PRESETS  @"Presets"
#define SDA_PRESET_CUSTOM   @"Custom"

#define STANDING_ACTION_TEXT        @"Standing"
#define STANDING_MENU_ICON          @"icon_standing.png"
#define STANDING_NOTIFICATION_ICON  @"desk_logo_128_2x.png"

#define SITTING_ACTION_TEXT         @"Sitting"
#define SITTING_MENU_ICON           @"icon_sitting.png"
#define SITTING_NOTIFICATION_ICON   @"desk_logo_sit_128_2x.png"

#define PAUSED_ACTION_TEXT          @"Paused"
#define PAUSED_MENU_ICON            @"icon_pausing.png"
#define ERROR_STATUS_TEXT           @"Error"

#define TRANSITIONING_ACTION_TEXT   @"Transitioning"
#define TRANSITIONING_MENU_ICON     @"icon_transitioning.png"

#define RESUME_TEXT_TITLE           @"Welcome back!"
#define RESUME_TEXT_FORMAT          @"Continuing %@"

#define NOTIFY_USER_TITLE           @"%@!"
#define NOTIFY_USER_FORMAT          @"Time to start %@"

#endif
