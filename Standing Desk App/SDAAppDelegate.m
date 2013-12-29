//
//  SDAAppDelegate.m
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppDelegate.h"
#import "SDAAppController.h"

@implementation SDAAppDelegate

SDAAppController* appController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    appController = [[SDAAppController alloc]init];
    [self assertTestWrite];
    [self assertTestRead];
    NSLog(@"Completed initial write/read test");
    
    // Reload settings
    [appController loadSettings];
    // Retest read
    [self assertTestRead];
}

-(void)assertTestWrite {
    appController.settings.standingSettings.volume = 1.0f;
    appController.settings.standingSettings.soundFile = @"Bludgeon.wav";
    [appController saveSettings];
}

-(void)assertTestRead {
    NSAssert(appController.settings.standingSettings.volume == 1.0f, @"Standing Volume Settings not expected value");
    
    NSAssert([appController.settings.standingSettings.soundFile isEqualToString:@"Bludgeon.wav"], @"Standing Sound Settings not expected value");
}

@end
