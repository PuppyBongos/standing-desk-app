//
//  SDAAppSettings.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppSettings.h"

@implementation SDAAppSettings
@synthesize sittingSettings;
@synthesize standingSettings;

@synthesize sittingInterval;
@synthesize standingInterval;
@synthesize idlePauseTime;

-(id)init {
    self = [super init];
    
    if(self) {
        self.sittingSettings = [[SDAAlertSetting alloc]init];
        self.standingSettings = [[SDAAlertSetting alloc]init];
        
        self.sittingInterval = SDA_DEFAULT_SIT_INTERVAL;
        self.standingInterval = SDA_DEFAULT_STAND_INTERVAL;
        self.idlePauseTime = SDA_DEFAULT_IDLE_TIME;
    }
    
    return self;
}

-(NSDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    // Create properties list
    [dict setValue:[NSNumber numberWithInt:sittingInterval]
             forKey:@"SitStateInterval"];
    [dict setValue:[NSNumber numberWithInt:standingInterval]
             forKey:@"StandStateInterval"];
    [dict setValue:[NSNumber numberWithInt:idlePauseTime]
             forKey:@"IdlePauseTime"];
    
    // Serialize the internal structures
    [dict setValue:[self.sittingSettings toDictionary] forKey:@"SitAlert"];
    [dict setValue:[self.standingSettings toDictionary] forKey:@"StandAlert"];
    
    return dict;
}

+(SDAAppSettings*)settingsFromFile:(NSString*)filePath {
    
    NSString* error = nil;
    NSPropertyListFormat plistFormat;
    
    // Read in the file, parsing into a plist dictionary
    NSData *fileContents = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    NSDictionary *plistContents = [NSPropertyListSerialization
                                   propertyListFromData:fileContents
                                   mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                   format:&plistFormat
                                   errorDescription:&error];
    
    SDAAppSettings* settings = [[SDAAppSettings alloc]init];
    if(plistContents) {
        settings.standingSettings = [SDAAlertSetting settingFromDictionary:
                                 [plistContents objectForKey:@"StandAlert"]];
        settings.sittingSettings = [SDAAlertSetting settingFromDictionary:
                                [plistContents objectForKey:@"SitAlert"]];
        
        settings.standingInterval = [[plistContents
                                  objectForKey:@"StandStateInterval"] intValue];
        
        settings.sittingInterval = [[plistContents
                                 objectForKey:@"SitStateInterval"] intValue];
        
        settings.idlePauseTime = [[plistContents
                               objectForKey:@"IdlePauseTime"] intValue];
        
    } else {
        NSLog(@"SDAAppSettings: Could not open file: %@.", error);
    }
    return settings;
}
@end
