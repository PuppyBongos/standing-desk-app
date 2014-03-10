//
//  SDAAppDelegate.h
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SDAConstants.h"
#import "SDAAppController.h"

@class MASShortcutView;

@interface SDAAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, SDAApplicationDelegate>

{
  NSStatusItem* statusItem;
}

#pragma mark - Main Program Menu Bar
@property (weak) IBOutlet NSMenu *statusMenu;

@property (weak) IBOutlet NSMenuItem *actionMenuItem;
@property (weak) IBOutlet NSMenuItem *timerMenuItem;
@property (weak) IBOutlet NSMenuItem *aboutMenuItem;
@property (weak) IBOutlet NSMenuItem *restartMenuItem;
@property (weak) IBOutlet NSMenuItem *pauseMenuItem;
@property (weak) IBOutlet NSMenuItem *snoozeMenuItem;
@property (weak) IBOutlet NSMenuItem *skipMenuItem;
@property (weak) IBOutlet NSMenuItem *prefMenuItem;
@property (weak) IBOutlet NSMenuItem *quitMenuItem;

#pragma mark - Preferences Window
@property (assign) IBOutlet NSWindow *prefWindow;

#pragma mark - Preferences->General tab
@property (weak) IBOutlet NSPopUpButton *prefWindowPresetPopUp;
@property (weak) IBOutlet NSTextField *prefWindowStandTime;
@property (weak) IBOutlet NSTextField *prefWindowSitTime;
@property (unsafe_unretained) IBOutlet NSButton *prefWindowIntervalApply;
@property (weak) IBOutlet NSTextField *prefWindowIdleTime;
@property (weak) IBOutlet NSTextField *prefWindowSnoozeTime;
@property (weak) IBOutlet NSButton *prefWindowLoginToggle;

#pragma mark - Preferences->Alerts tab
@property (weak) IBOutlet NSPopUpButton *prefWindowSitAlertSystemSoundPopUp;
@property (weak) IBOutlet NSSlider *prefWindowSitVolume;
@property (weak) IBOutlet NSPopUpButton *prefWindowStandAlertSystemSoundPopUp;
@property (weak) IBOutlet NSSlider *prefWindowStandVolume;

#pragma mark - Preferences->Shortcuts tab
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutViewPause;
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutViewSkip;

#pragma mark - Transitioning
@property (assign) IBOutlet NSWindow *transWindow;
@property (weak) IBOutlet NSTextField *transWindowLastCompletedAction;
@property (weak) IBOutlet NSTextField *transWindowNextActionToStart;
@property (weak) IBOutlet NSButton *transWindowContinueBtn;
@property (weak) IBOutlet NSButton *transWindowRestartBtn;
@property (weak) IBOutlet NSButton *transWindowSnoozeBtn;
@property (weak) IBOutlet NSButton *transWindowSkipBtn;

- (void)transNotificationClicked;

@end
