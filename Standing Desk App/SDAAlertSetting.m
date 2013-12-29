//
//  SDAAlert.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAlertSetting.h"

@implementation SDAAlertSetting
@synthesize soundFile;
@synthesize isMute;
@synthesize volume;

-(id)init {
    self = [super init];
    if(self) {
        self.soundFile = @"";
        self.isMute = SDA_ALERT_DEFAULT_MUTE;
        self.volume = SDA_ALERT_DEFAULT_VOLUME;
    }
    return self;
}

-(NSDictionary*) toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setValue:soundFile forKey:@"SoundFile"];
    [dictionary setValue:[NSNumber numberWithBool:isMute] forKey:@"IsMute"];
    [dictionary setValue:[NSNumber numberWithFloat:volume] forKey:@"Volume"];
    return dictionary;
}

+(SDAAlertSetting*) settingFromDictionary:(NSDictionary*)dict {
    if(!dict) {
        NSLog(@"SDAAlertSettings: Dictionary is nil.");
        return nil;
    }
    
    SDAAlertSetting* setting = [[SDAAlertSetting alloc]init];
    setting.soundFile = [dict valueForKey:@"SoundFile"];
    setting.isMute = [[dict valueForKey:@"IsMute"] boolValue];
    setting.volume = [[dict valueForKey:@"Volume"] floatValue];
    return setting;
}
@end
