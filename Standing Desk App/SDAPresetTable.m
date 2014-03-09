//
//  SDAPresetTable.m
//  Standing Desk App
//
//  Created by David Vera on 3/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import "SDAPresetTable.h"

@implementation SDAPresetTable

-(id)init {
    self = [super init];
    if(self) {
        presetTable = nil;
    }
    return self;
}

+(SDAPresetTable*)tableFromDictionary:(NSDictionary*)dict {
    
    // Values in this dictionary are of type
    // SDASettingsPreset
    NSMutableDictionary *newEntries = [NSMutableDictionary dictionary];
    
    if(!dict) {
        NSLog(@"SDAPresetTable: Dictionary is NULL");
        return nil;
    }
    
    // Create explicit setting preset objects as entries
    // of our preset table.
    for(id key in dict) {
        SDASettingPreset *preset = [SDASettingPreset presetFromDictionary:[dict objectForKey:key]];
                                    
        if(preset) {
            [newEntries setObject:preset forKey:key];
        }
    }
    
    // Create our table and plop them in.
    SDAPresetTable *table = [[SDAPresetTable alloc]init];
    table->presetTable = newEntries;
    return table;
}

-(SDASettingPreset *)presetByName:(NSString*)presetName {
    return (SDASettingPreset*)[presetTable objectForKey:presetName];
}
@end
