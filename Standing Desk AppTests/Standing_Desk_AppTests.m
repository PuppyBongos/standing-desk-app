//
//  Standing_Desk_AppTests.m
//  Standing Desk AppTests
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDAAppController.h"

@interface Standing_Desk_AppTests : XCTestCase

@end

@implementation Standing_Desk_AppTests

SDAAppController* testController = nil;

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    
    
    testController = [[SDAAppController alloc]init];
}

- (void)tearDown
{
    // Restore old controller's values
    
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testSettingsShouldBePresentWhenControllerInitialized {
    XCTAssertNotNil(testController.settings, @"Settings should not be NIL when controller created.");
}

-(void)testSettingsShouldBeDefaultIfNoConfigCreated {
    XCTAssertTrue(testController.settings.sittingInterval == SDA_DEFAULT_SIT_INTERVAL, @"Loaded settings do not match expected defaults");
    
    XCTAssertTrue(testController.settings.idlePauseTime == SDA_DEFAULT_IDLE_TIME, @"Loaded settings do not match expected defaults");
    
    XCTAssertTrue(testController.settings.standingInterval == SDA_DEFAULT_STAND_INTERVAL, @"Loaded settings do not match expected defaults");
}

-(void)testSettingsShouldPersistWhenSavingAndReloadingFromDiskWithNewInstance {
    
    int expectedInterval = 128834;
    
    // Start fresh, check interval to modify is at default value
    testController.settings = [SDAAppSettings defaultSettings];
    
    // Modify settings to new one
    testController.settings.sittingInterval = expectedInterval;
    [testController saveSettings];
    
    XCTAssertFalse(testController.settings.sittingInterval == SDA_DEFAULT_SIT_INTERVAL, @"Current settings do not match modified values.");
    
    // Replace the settings in the controller
    testController.settings = [SDAAppSettings defaultSettings];
    
    // Reload settings from disk
    [testController loadSettings];
    XCTAssertTrue(testController.settings.sittingInterval == expectedInterval, @"Loaded settings from disk do not match expected values");
}

/* This method should be split up into unit tests for the SDAAppSettings & SDAAlertSetting classes */
-(void)longTestExample {
    
    SDAAppController *appController = [[SDAAppController alloc]init];
    // Insert code here to initialize your application
    
    SDAAppSettings* settings = appController.settings;
    NSAssert(settings.standingInterval == 15, @"Stand Settings do not match disk.");
    NSAssert(settings.sittingInterval == 15, @"Sit Settings do not match disk.");
    NSAssert(settings.idlePauseTime == 5, @"Idle Settings do not match disk.");
    
    SDAAlertSetting *stand = settings.standingSettings;
    NSAssert(stand != nil, @"Stand Alert Settings NIL!");
    NSAssert([stand.soundFile isEqualToString:@"Sound.wav"], @"Soundfile is UNDEF / NIL");
    NSAssert(stand.volume == 0.5f, @"Standing Volume not match disk ");

    SDAAlertSetting *sit = settings.sittingSettings;
    NSAssert(sit != nil, @"Sit Alert Settings NIL!");
    NSAssert([stand.soundFile isEqualToString:@"Sound.wav"], @"Sit is UNDEF / NIL");
    NSAssert(stand.volume == 0.5f, @"Sit Volume not match disk ");

}

@end
