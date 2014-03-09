//
//  SDASettingPreset.h
//  Standing Desk App
//
//  Created by David Vera on 3/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAConstants.h"

@interface SDASettingPreset : NSObject

/** Time, in seconds, of standing state */
@property int standingInterval;

/** Time, in seconds, of sitting state */
@property int sittingInterval;

+(SDASettingPreset*)presetFromDictionary:(NSDictionary *)dict;
@end
