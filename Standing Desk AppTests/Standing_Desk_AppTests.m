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

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)longTestExample {
    
    SDAAppController *appController = [[SDAAppController alloc]init];
    // Insert code here to initialize your application
    
    NSAssert(appController != nil, @"App controller is NIL!");
    NSAssert(appController.settings != nil, @"App settings are NIL!");
    
    SDAAppSettings* settings = appController.settings;
    NSAssert(settings.standingInterval == 15, @"Stand Settings do not match disk.");
    NSAssert(settings.sittingInterval == 15, @"Sit Settings do not match disk.");
    NSAssert(settings.idlePauseTime == 5, @"Idle Settings do not match disk.");
    
    SDAAlertSetting *stand = settings.standingSettings;
    NSAssert(stand != nil, @"Stand Alert Settings NIL!");
    NSAssert([stand.soundFile isEqualToString:@"Sound.wav"], @"Soundfile is UNDEF / NIL");
    NSAssert(stand.volume == 0.5f, @"Standing Volume not match disk ");
    NSAssert(!stand.isMute, @"Standing Mute not match disk ");
    
    
    SDAAlertSetting *sit = settings.sittingSettings;
    NSAssert(sit != nil, @"Sit Alert Settings NIL!");
    NSAssert([stand.soundFile isEqualToString:@"Sound.wav"], @"Sit is UNDEF / NIL");
    NSAssert(stand.volume == 0.5f, @"Sit Volume not match disk ");
    NSAssert(!stand.isMute, @"Sit Mute not match disk ");

}

@end
