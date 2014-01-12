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
#define SITTING_ACTION_TEXT @"Sitting"
#define SITTING_MENU_ICON @"icon_sitting.png"
#define PAUSED_ACTION_TEXT @"Paused"
#define ERROR_STATUS_TEXT @"Error"

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
@property (weak) IBOutlet NSComboBox *prefWindowStandTime;
@property (weak) IBOutlet NSComboBox *prefWindowSitTime;
@property (weak) IBOutlet NSComboBox *prefWindowIdleTime;
@property (weak) IBOutlet NSComboBox *prefWindowSnoozeTime;

#pragma mark - Preferences->Alerts tab
@property (weak) IBOutlet NSComboBox *prefWindowSitAlertComboBox;
@property (weak) IBOutlet NSSlider *prefWindowSitVolume;
@property (weak) IBOutlet NSComboBox *prefWindowStandAlertComboBox;
@property (weak) IBOutlet NSSlider *prefWindowStandVolume;

#pragma mark - Preferences->Login tab
@property (weak) IBOutlet NSButton *prefWindowLoginToggle;

- (void)addAppAsLoginItem;
- (void)deleteAppFromLoginItem;

@end
