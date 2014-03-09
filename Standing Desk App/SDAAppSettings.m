//
//  SDAAppSettings.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppSettings.h"

@implementation SDAAppSettings
@synthesize isFirstTimeRunning;

@synthesize sittingSettings;
@synthesize standingSettings;

@synthesize currentPreset;

@synthesize sittingInterval = _sittingInterval;
@synthesize standingInterval = _standingInterval;
@synthesize idlePauseTime;
@synthesize snoozeTime;
@synthesize isLoginItem;

int _sittingInterval;
int _standingInterval;

-(id)init {
    self = [super init];
    
    if(self) {
        self.sittingSettings = [[SDAAlertSetting alloc]init];
        self.standingSettings = [[SDAAlertSetting alloc]init];
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
    [dict setValue:[NSNumber numberWithInt:[self sittingInterval]]
             forKey:UD_SIT_INTERVAL];
    [dict setValue:[NSNumber numberWithInt:[self standingInterval]]
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
    
    [ud setValue:self.currentPreset forKey:UD_PRESET];
    [ud setBool:isFirstTimeRunning forKey:UD_FIRST_TIME];
    
    // Save the interval *members* and not the preset versions.
    [ud setInteger:_sittingInterval forKey:UD_SIT_INTERVAL];
    [ud setInteger:_standingInterval forKey:UD_STAND_INTERVAL];
    [ud setInteger:idlePauseTime forKey:UD_IDLE_TIME];
    [ud setInteger:snoozeTime forKey:UD_SNOOZE_TIME];
    [ud setBool:isLoginItem forKey:UD_LOGIN];
    [ud setValue:[self.sittingSettings toDictionary] forKey:UD_SIT_ALERT];
    [ud setValue:[self.standingSettings toDictionary] forKey:UD_STAND_ALERT];
    
    [ud synchronize];
}

-(void)setStandingInterval:(int)standingInterval {
    _standingInterval = standingInterval;
}

-(void)setSittingInterval:(int)sittingInterval {
    _sittingInterval = sittingInterval;
}

-(int)sittingInterval {
    if(!currentPreset ||
       [self.currentPreset isEqualToString:@""] ||
       [self.currentPreset isEqualToString:@"Custom"]) {
        return _sittingInterval;
    } else {
        
        // Presets weren't provided, error out.
        if(!self.presetTable)
            return -1;
        
        // Try to pull it out
        SDASettingPreset *preset = [self.presetTable presetByName:self.currentPreset];
        if(preset) return preset.sittingInterval;
        else
            return -1;
    }
}

-(int)standingInterval {
    if(!currentPreset ||
       [self.currentPreset isEqualToString:@""] ||
       [self.currentPreset isEqualToString:@"Custom"]) {
        return _standingInterval;
    } else {
        
        // Presets weren't provided, error out.
        if(!self.presetTable)
            return -1;
        
        // Try to pull it out
        SDASettingPreset *preset = [self.presetTable presetByName:self.currentPreset];
        if(preset) return preset.standingInterval;
        else
            return -1;
    }
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
    
    id value = [userPreferences objectForKey:UD_PRESET];
    NSString *preset = value ? value : @"Custom";
    
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

-(int)sitIntervalForPreset:(NSString*)presetName {
    
    if(!self.presetTable)
        return -1;
    
    if([presetName isEqualToString:@"Custom"]) {
        return _sittingInterval;
    }
    
    SDASettingPreset *preset = [self.presetTable presetByName:presetName];
    
    if(preset) {
        return preset.sittingInterval;
    }
    return -1;
}

-(int)standIntervalForPreset:(NSString*)presetName {
    
    if(!self.presetTable)
        return -1;
    
    if([presetName isEqualToString:@"Custom"]) {
        return _standingInterval;
    }
    
    SDASettingPreset *preset = [self.presetTable presetByName:presetName];
    
    if(preset) {
        return preset.standingInterval;
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
