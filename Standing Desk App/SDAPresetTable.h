//
//  SDAPresetTable.h
//  Standing Desk App
//
//  Created by David Vera on 3/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDASettingPreset.h"

@interface SDAPresetTable : NSObject {
    NSDictionary *presetTable;
}

-(SDASettingPreset*)presetByName:(NSString*)presetName;

+(SDAPresetTable*)tableFromDictionary:(NSDictionary*)dict;
@end
