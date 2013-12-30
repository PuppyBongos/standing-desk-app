//
//  SDAAppController.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppController.h"

@implementation SDAAppController
@synthesize settings;

-(id)init {
    self = [super init];
    if(self) {
        
        // Start with empty settings
        self.settings = [SDAAppSettings defaultSettings];
    }
    return self;
}

-(void)loadSettings {
    self.settings = [SDAAppSettings settingsFromFile:[self getConfigPath]];
}

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

-(void)saveSettings {
    
    NSString* error = nil;
    
    NSDictionary* pList = [self.settings toDictionary];
    
    // Save our settings into our configuration plist
    NSData* data = [NSPropertyListSerialization dataFromPropertyList:pList format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    NSString *configPath = [self getConfigPath];
    if(data) {
        [data writeToFile:configPath atomically:YES];
    }
    
    if(error) {
        NSLog(@"SDAAppController: Settings failed to save. %@", error);
    }
}
@end
