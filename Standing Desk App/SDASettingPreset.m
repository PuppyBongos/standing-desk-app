//
//  SDASettingPreset.m
//  Standing Desk App
//
//  Created by David Vera on 3/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import "SDASettingPreset.h"

@implementation SDASettingPreset

@synthesize standingInterval, sittingInterval;

-(id) init {
    self = [super init];
    if(self) {
        standingInterval = SDA_DEFAULT_STAND_INTERVAL;
        sittingInterval = SDA_DEFAULT_SIT_INTERVAL;
    }
    return self;
}

+(SDASettingPreset*)presetFromDictionary:(NSDictionary *)dict {
    
    // Return an instance if the dictionary is valid.
    if(dict) {
        SDASettingPreset *preset = [[SDASettingPreset alloc]init];
        
        self.standingInterval = [[dict objectForKey:UD_STAND_INTERVAL] integerValue];
        
        self.sittingInterval = [[dict objectForKey:UD_SIT_INTERVAL] integerValue];
        return preset;
    }
    return nil;
}
@end
