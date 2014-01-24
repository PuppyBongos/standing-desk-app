//
//  SDAAppDelegate.h
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDAAppController.h"

#define STANDING_ACTION_TEXT @"Standing"
#define STANDING_MENU_ICON @"icon_standing.png"
#define STANDING_NOTIFICATION_ICON @"desk_logo_128_2x.png"

#define SITTING_ACTION_TEXT @"Sitting"
#define SITTING_MENU_ICON @"icon_sitting.png"
#define SITTING_NOTIFICATION_ICON @"desk_logo_sit_128_2x.png"

#define PAUSED_ACTION_TEXT @"Paused"
#define PAUSED_MENU_ICON @"icon_pausing.png"
#define ERROR_STATUS_TEXT @"Error"

#define RESUME_TEXT_TITLE  @"Welcome back!"
#define RESUME_TEXT_FORMAT @"Continuing %@"

#define NOTIFY_USER_TITLE   @"%@!"
#define NOTIFY_USER_FORMAT  @"Time to start %@"

@interface SDAAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, SDAApplicationDelegate>

{
  NSStatusItem* statusItem;
}

#pragma mark - Main Program Menu Bar
@property (weak) IBOutlet NSMenu *statusMenu;

@property (weak) IBOutlet NSMenuItem *actionMenuItem;
@property (weak) IBOutlet NSMenuItem *timerMenuItem;
@property (weak) IBOutlet NSMenuItem *pauseMenuItem;
@property (weak) IBOutlet NSMenuItem *snoozeMenuItem;
@property (weak) IBOutlet NSMenuItem *skipMenuItem;
@property (weak) IBOutlet NSMenuItem *prefMenuItem;
@property (weak) IBOutlet NSMenuItem *quitMenuItem;

#pragma mark - Preferences Window
@property (assign) IBOutlet NSWindow *prefWindow;
@property (weak) IBOutlet NSButton *prefWindowCancelBtn;
@property (weak) IBOutlet NSButton *prefWindowSaveBtn;

#pragma mark - Preferences->General tab
@property (weak) IBOutlet NSTextField *prefWindowStandTime;
@property (weak) IBOutlet NSTextField *prefWindowSitTime;
@property (weak) IBOutlet NSTextField *prefWindowIdleTime;
@property (weak) IBOutlet NSTextField *prefWindowSnoozeTime;
@property (weak) IBOutlet NSButton *prefWindowLoginToggle;

#pragma mark - Preferences->Alerts tab
@property (weak) IBOutlet NSPopUpButton *prefWindowSitAlertSystemSoundPopUp;
@property (weak) IBOutlet NSSlider *prefWindowSitVolume;
@property (weak) IBOutlet NSPopUpButton *prefWindowStandAlertSystemSoundPopUp;
@property (weak) IBOutlet NSSlider *prefWindowStandVolume;

- (void)addAppAsLoginItem;
- (void)deleteAppFromLoginItem;

- (void)openEventOptionsWindow;

@end
