//
//  SDAAppSettings.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppSettings.h"

#define SDA_CONFIG_PRESETS  @"Presets"
#define SDA_PRESET_CUSTOM   @"Custom"

#define UD_PRESET           @"Preset"
#define UD_LOGIN            @"LoginItemStatus"
#define UD_FIRST_TIME       @"FirstTimeRunning"
#define UD_STAND_INTERVAL   @"StandStateInterval"
#define UD_SIT_INTERVAL     @"SitStateInterval"
#define UD_IDLE_TIME        @"IdlePauseTime"
#define UD_SNOOZE_TIME      @"SnoozeTime"

#define UD_STAND_ALERT      @"StandAlert"
#define UD_SIT_ALERT        @"SitAlert"

@implementation SDAAppSettings
@synthesize isFirstTimeRunning;

@synthesize sittingSettings;
@synthesize standingSettings;

@synthesize currentPreset;

@synthesize sittingInterval;
@synthesize standingInterval;
@synthesize idlePauseTime;
@synthesize snoozeTime;
@synthesize isLoginItem;

NSDictionary* presetListings;

-(id)init {
    self = [super init];
    
    if(self) {
        self.sittingSettings = [[SDAAlertSetting alloc]init];
        self.standingSettings = [[SDAAlertSetting alloc]init];
        
        presetListings = [self getPresets];
    }
    
    return self;
}

+(SDAAppSettings*)defaultSettings {
    SDAAppSettings* settings = [[SDAAppSettings alloc]init];
    
    settings.isFirstTimeRunning = SDA_DEFAULT_FIRST_TIME;
    settings.sittingInterval = SDA_DEFAULT_SIT_INTERVAL;
    settings.standingInterval = SDA_DEFAULT_STAND_INTERVAL;
    settings.idlePauseTime = SDA_DEFAULT_IDLE_TIME;
    settings.snoozeTime = SDA_DEFAULT_SNOOZE_TIME;
    settings.isLoginItem = false;
    
    settings.currentPreset = SDA_DEFAULT_PRESET;
    
    settings.sittingSettings.soundFile = @"Sit";
    settings.standingSettings.soundFile = @"Stand";

    return settings;
}

-(NSDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    // Create properties list
    [dict setValue:[NSNumber numberWithBool:isFirstTimeRunning] forKey:UD_FIRST_TIME];
    [dict setValue:[NSNumber numberWithInt:sittingInterval]
             forKey:UD_SIT_INTERVAL];
    [dict setValue:[NSNumber numberWithInt:standingInterval]
             forKey:UD_STAND_INTERVAL];
    [dict setValue:[NSNumber numberWithInt:idlePauseTime]
             forKey:UD_IDLE_TIME];
    [dict setValue:[NSNumber numberWithInt:snoozeTime]
            forKey:UD_SNOOZE_TIME];
    [dict setValue:[NSNumber numberWithBool:isLoginItem]
            forKey:UD_LOGIN];

    // Serialize the internal structures
    [dict setValue:[self.sittingSettings toDictionary] forKey:UD_SIT_ALERT];
    [dict setValue:[self.standingSettings toDictionary] forKey:UD_STAND_ALERT];
    [dict setValue:self.currentPreset forKey:UD_PRESET];
    
    return dict;
}

-(void)writeSettings {
    
    // Writes the settings to the userDefaults plist. Presets
    // are checked to see if the Sit/Stand interval are to be
    // assigned from the sda_config preset listing. If
    // no preset matches, the preset "Custom" is assigned and
    // whichever settings are currently applied will be written
    // to the file.
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // Check for presets available
    if(self.currentPreset) {
        // Try to read from the sda files.
        
        NSDictionary *presetValues = presetListings[self.currentPreset];
        
        // Load the presets into our structure
        if(presetValues) {
            sittingInterval = [presetValues[UD_SIT_INTERVAL] intValue];
            standingInterval = [presetValues[UD_STAND_INTERVAL] intValue];
        } else {
            
            self.currentPreset = SDA_PRESET_CUSTOM;
        }
        
    } else {
        
        // Default to custom
        self.currentPreset = SDA_PRESET_CUSTOM;
    }
    
    [ud setValue:self.currentPreset forKey:UD_PRESET];
    [ud setBool:isFirstTimeRunning forKey:UD_FIRST_TIME];
    [ud setInteger:sittingInterval forKey:UD_SIT_INTERVAL];
    [ud setInteger:standingInterval forKey:UD_STAND_INTERVAL];
    [ud setInteger:idlePauseTime forKey:UD_IDLE_TIME];
    [ud setInteger:snoozeTime forKey:UD_SNOOZE_TIME];
    [ud setBool:isLoginItem forKey:UD_LOGIN];
    [ud setValue:[self.sittingSettings toDictionary] forKey:UD_SIT_ALERT];
    [ud setValue:[self.standingSettings toDictionary] forKey:UD_STAND_ALERT];
}

+(SDAAppSettings*)settings {
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    
    SDAAppSettings* settings = [SDAAppSettings defaultSettings];
    
    settings.isFirstTimeRunning = [[userPreferences objectForKey:UD_FIRST_TIME] boolValue];
        
    settings.standingSettings = [SDAAlertSetting settingFromDictionary:
                                 [userPreferences objectForKey:UD_STAND_ALERT]];
    settings.sittingSettings = [SDAAlertSetting settingFromDictionary:
                                [userPreferences objectForKey:UD_SIT_ALERT]];
        
    settings.standingInterval = [[userPreferences
                                  objectForKey:UD_STAND_INTERVAL] intValue];
        
    settings.sittingInterval = [[userPreferences
                                 objectForKey:UD_SIT_INTERVAL] intValue];
        
    settings.idlePauseTime = [[userPreferences
                               objectForKey:UD_IDLE_TIME] intValue];
        
    settings.snoozeTime = [[userPreferences objectForKey:UD_SNOOZE_TIME] intValue];

    settings.isLoginItem = [[userPreferences objectForKey:UD_LOGIN] boolValue];
    
    NSString *preset = [[userPreferences objectForKey:UD_PRESET] stringValue];
    
    // Overwrite if valid
    if(preset) settings.currentPreset = preset;

    return settings;
}

-(NSDictionary*)getPresets {
    NSDictionary* configPlist = [NSDictionary dictionaryWithContentsOfFile:[self getConfigPath]];
    
    
    if(!configPlist) {
        // Return a blank dictionary if no presets defined
        return [[NSDictionary alloc]init];
    }
    
    NSDictionary *presets = configPlist[SDA_CONFIG_PRESETS];
    if(!presets)
        presets = [[NSDictionary alloc]init];

    return presets;
}

-(int)sitIntervalForPreset:(NSString*)preset {
    if(presetListings[preset]) {
        return (int)[presetListings[preset][UD_SIT_INTERVAL] intValue];
    }
    return -1;
}

-(int)standIntervalForPreset:(NSString*)preset {
    if(presetListings[preset]) {
        return (int)[presetListings[preset][UD_STAND_INTERVAL] intValue];
    }
    return -1;
}

/** Retrieves the file path of the SDA App's configuration file */
-(NSString*) getConfigPath {
    NSString* appPath = [NSSearchPathForDirectoriesInDomains
                         (NSDocumentDirectory, NSUserDomainMask, YES)
                         objectAtIndex:0];
    
    // Get a full path to the application configuration file
    NSString* configPath = [appPath stringByAppendingPathComponent:@"sda_config.plist"];
    
    // Check if this exists locally. If not, try the bundle path
    if(![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        configPath = [[NSBundle mainBundle] pathForResource:@"sda_config"
                                                     ofType:@"plist"];
    }
    
    return configPath;
}
@end
