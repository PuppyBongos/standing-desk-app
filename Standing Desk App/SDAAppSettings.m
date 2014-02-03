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

@synthesize sittingInterval;
@synthesize standingInterval;
@synthesize idlePauseTime;
@synthesize snoozeTime;
@synthesize isLoginItem;

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
    [dict setValue:[NSNumber numberWithBool:isFirstTimeRunning] forKey:@"FirstTimeRunning"];
    [dict setValue:[NSNumber numberWithInt:sittingInterval]
             forKey:@"SitStateInterval"];
    [dict setValue:[NSNumber numberWithInt:standingInterval]
             forKey:@"StandStateInterval"];
    [dict setValue:[NSNumber numberWithInt:idlePauseTime]
             forKey:@"IdlePauseTime"];
    [dict setValue:[NSNumber numberWithInt:snoozeTime]
            forKey:@"SnoozeTime"];
    [dict setValue:[NSNumber numberWithBool:isLoginItem]
            forKey:@"LoginItemStatus"];

    // Serialize the internal structures
    [dict setValue:[self.sittingSettings toDictionary] forKey:@"SitAlert"];
    [dict setValue:[self.standingSettings toDictionary] forKey:@"StandAlert"];
    [dict setValue:self.currentPreset forKey:@"Preset"];
    
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
        
        NSDictionary *presetValues = [self getSettingsForPreset:self.currentPreset];
        
        // Load the presets into our structure
        if(presetValues) {
            sittingInterval = [presetValues[@"SitStateInterval"] intValue];
            standingInterval = [presetValues[@"StandStateInterval"] intValue];
        } else {
            
            self.currentPreset = @"Custom";
        }
        
    } else {
        
        // Default to custom
        self.currentPreset = @"Custom";
    }
    
    [ud setValue:self.currentPreset forKey:@"Preset"];
    [ud setBool:isFirstTimeRunning forKey:@"FirstTimeRunning"];
    [ud setInteger:sittingInterval forKey:@"SitStateInterval"];
    [ud setInteger:standingInterval forKey:@"StandStateInterval"];
    [ud setInteger:idlePauseTime forKey:@"IdlePauseTime"];
    [ud setInteger:snoozeTime forKey:@"SnoozeTime"];
    [ud setBool:isLoginItem forKey:@"LoginItemStatus"];
    [ud setValue:[self.sittingSettings toDictionary] forKey:@"SitAlert"];
    [ud setValue:[self.standingSettings toDictionary] forKey:@"StandAlert"];
}

+(SDAAppSettings*)settings {
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    
    SDAAppSettings* settings = [SDAAppSettings defaultSettings];
    
    settings.isFirstTimeRunning = [[userPreferences objectForKey:@"FirstTimeRunning"] boolValue];
        
    settings.standingSettings = [SDAAlertSetting settingFromDictionary:
                                 [userPreferences objectForKey:@"StandAlert"]];
    settings.sittingSettings = [SDAAlertSetting settingFromDictionary:
                                [userPreferences objectForKey:@"SitAlert"]];
        
    settings.standingInterval = [[userPreferences
                                  objectForKey:@"StandStateInterval"] intValue];
        
    settings.sittingInterval = [[userPreferences
                                 objectForKey:@"SitStateInterval"] intValue];
        
    settings.idlePauseTime = [[userPreferences
                               objectForKey:@"IdlePauseTime"] intValue];
        
    settings.snoozeTime = [[userPreferences objectForKey:@"SnoozeTime"] intValue];

    settings.isLoginItem = [[userPreferences objectForKey:@"LoginItemStatus"] boolValue];
    
    NSString *preset = [[userPreferences objectForKey:@"Preset"] stringValue];
    
    // Overwrite if valid
    if(preset) settings.currentPreset = preset;

    return settings;
}

-(NSDictionary*)getSettingsForPreset:(NSString*)preset {
    NSDictionary* presets = [NSDictionary dictionaryWithContentsOfFile:[self getConfigPath]];
    
    
    if(!presets) {
        return nil;
    }
    else if(!presets[@"Presets"]) {
        return nil;
    }
        
    return presets[@"Presets"][preset];
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
