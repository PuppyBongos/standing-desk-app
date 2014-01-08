//
//  SDAAppDelegate.m
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppDelegate.h"
#import "SDAAppController.h"
#import "SystemSounds.h"

@implementation SDAAppDelegate

SDAAppController* appController;
NSString *appName;
NSSound *sitSound;
NSSound *standSound;

#pragma mark - Event Handlers
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  appName = NSBundle.mainBundle.infoDictionary  [@"CFBundleName"];

    // Create our brain
  appController = [[SDAAppController alloc]init];
  [appController loadSettings];
  [appController setDelegate:self];
  [appController scheduleSit];
    
    // Hook into the user notification center
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id<NSUserNotificationCenterDelegate>)self];

  /* set up main menu */
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:_statusMenu];
  [statusItem setImage:[NSImage imageNamed:SITTING_MENU_ICON]];
  [statusItem setHighlightMode:YES];
  [statusItem setToolTip:appName];
  [_statusMenu setAutoenablesItems:NO];

  [_actionMenuItem setEnabled:false];
  [self updateActionMenuItem];
  [_timerMenuItem setEnabled:false];

  /* Load alert comboboxes with system sounds */
  [_prefWindowSitAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];
  [_prefWindowSitAlertComboBox insertItemWithObjectValue:@"" atIndex:0];
  [_prefWindowStandAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];
  [_prefWindowStandAlertComboBox insertItemWithObjectValue:@"" atIndex:0];

  [_prefWindow setDelegate:self];
}

- (void)actionPeriodDidComplete:(SDAAppController *)sender actionState:(SDAActionState)status {
  [self sendUserNotification];
  [self updateActionMenuItem];
  if (appController.currentActionState == SDAActionStateStanding) {
    [appController scheduleSit];
  }
  else {
    [appController scheduleStand];
  }
}

- (void)runningTickDidOccur:(SDAAppController *)sender {
  [self updateTimerMenuItem];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  // Preferences Buttons
//  [_prefWindowCancelBtn setBezelStyle:NSRoundedBezelStyle];
//  [_prefWindow setDefaultButtonCell:[_prefWindowCancelBtn cell]];
//  [_prefWindowSaveBtn setBezelStyle:NSRoundedBezelStyle];

  // Preferences->General
  [_prefWindowStandTime setStringValue:[self stringSecToMin:appController.settings.standingInterval]];
  [_prefWindowSitTime setStringValue:[self stringSecToMin:appController.settings.sittingInterval]];
  [_prefWindowIdleTime setStringValue:[self stringSecToMin:appController.settings.idlePauseTime]];
  [_prefWindowSnoozeTime setStringValue:[self stringSecToMin:appController.settings.snoozeTime]];

  // Preferences->Alerts
  [_prefWindowSitAlertComboBox setStringValue:appController.settings.sittingSettings.soundFile];
  [_prefWindowSitVolume setFloatValue:appController.settings.sittingSettings.volume];
  [_prefWindowStandAlertComboBox setStringValue:appController.settings.standingSettings.soundFile];
  [_prefWindowStandVolume setFloatValue:appController.settings.standingSettings.volume];
}

#pragma mark - Preferences->General
- (IBAction)onStandTimeComboBoxChange:(id)sender {

}
- (IBAction)onSitTimeComboBoxChange:(id)sender {

}
- (IBAction)onIdleTimeComboBoxChange:(id)sender {

}
- (IBAction)onSnoozeTimeComboBoxChange:(id)sender {
  }

#pragma mark - Preferences->Alerts
- (IBAction)onSitAlertComboBoxChange:(id)sender {
  sitSound = [NSSound soundNamed:[_prefWindowSitAlertComboBox stringValue]];
  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [sitSound play];
}
- (IBAction)onSitAlertVolumeChange:(id)sender {
  sitSound = [NSSound soundNamed:[_prefWindowSitAlertComboBox stringValue]];
  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [sitSound play];
}
- (IBAction)onStandAlertComboBoxChange:(id)sender {
  standSound = [NSSound soundNamed:[_prefWindowStandAlertComboBox stringValue]];
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound play];
}
- (IBAction)onStandAlertVolumeChange:(id)sender {
  standSound = [NSSound soundNamed:[_prefWindowStandAlertComboBox stringValue]];
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound play];
}

#pragma mark - Preferences->Buttons
- (IBAction)onPrefCancel:(id)sender {
  [appController loadSettings];
  [_prefWindow performClose:self];
}
- (IBAction)onPrefSave:(id)sender {
  [self saveUIToAppSettings];
  [appController saveSettings];
  [_prefWindow performClose:self];
}

#pragma mark - Menu Items
- (IBAction)onMenuPause:(id)sender {
  if (appController.currentStatus == SDAStatusRunning) {
    [appController pauseTimer];
    [self updateActionMenuItem];
    [sender setTitle:@"Resume"];
  }
  else if (appController.currentStatus == SDAStatusPaused) {
    [appController resumeTimer];
    [self updateActionMenuItem];
    [sender setTitle:@"Pause"];
  }
}
- (IBAction)onMenuSnooze:(id)sender {
  [appController snooze];
}
- (IBAction)onMenuSkip:(id)sender {
  [appController skipToNext];
  [self updateActionMenuItem];
}
- (IBAction)onMenuQuit:(id)sender {
  NSLog(@"%@ quit", appName);
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Menu Item private methods
/** 
 * Convenience method that converts seconds to minutes 
 * as a string to place into UI text fields.
 */
- (NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}

/**
 * Converts minutes to seconds.
 */
- (int)intMinToSec:(int)minutes {
  return minutes * 60;
}
- (void)updateActionMenuItem {
  switch (appController.currentActionState) {
    case SDAActionStateSitting:
      self.actionMenuItem.title = SITTING_ACTION_TEXT;
      [statusItem setImage:[NSImage imageNamed:SITTING_MENU_ICON]];
      break;
    case SDAActionStateStanding:
      self.actionMenuItem.title = STANDING_ACTION_TEXT;
      [statusItem setImage:[NSImage imageNamed:STANDING_MENU_ICON]];
      break;
    case SDAActionStateNone:
      self.actionMenuItem.title = ERROR_STATUS_TEXT;
      break;
    default:
      self.actionMenuItem.title = @"";
      break;
  }
  if (appController.currentStatus == SDAStatusPaused)
  {
    self.actionMenuItem.title = PAUSED_ACTION_TEXT;
  }
}
- (void)updateTimerMenuItem {
  self.timerMenuItem.title = appController.stringFromTimeLeft;
}

/**
 *  Saves UI preference values to
    local appsettings values
 */
- (void)saveUIToAppSettings {
  appController.settings.standingInterval = [self intMinToSec:_prefWindowStandTime.integerValue];
  appController.settings.sittingInterval = [self intMinToSec:_prefWindowSitTime.integerValue];
  appController.settings.idlePauseTime = [self intMinToSec:_prefWindowIdleTime.integerValue];
  appController.settings.snoozeTime = [self intMinToSec:_prefWindowSnoozeTime.integerValue];

  appController.settings.sittingSettings.soundFile = [_prefWindowSitAlertComboBox stringValue];
  appController.settings.sittingSettings.volume = [_prefWindowSitVolume floatValue];
  appController.settings.standingSettings.soundFile = [_prefWindowStandAlertComboBox stringValue];
  appController.settings.standingSettings.volume = [_prefWindowStandVolume floatValue];
}

/**
 *  Plays a sound for the current action state.
 */
- (void)playSounds {
  NSSound *sitSound = [NSSound soundNamed:appController.settings.sittingSettings.soundFile];
  NSSound *standSound = [NSSound soundNamed:appController.settings.standingSettings.soundFile];

  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [standSound setVolume:appController.settings.standingSettings.volume];

  switch (appController.currentActionState) {
    case SDAActionStateSitting:
      [sitSound play];
      break;
    case SDAActionStateStanding:
      [standSound play];
      break;
    default:
      break;
  }
}

/** 
 * Sends a notification alert to the OSX Notification indicating the current status and action a user should take.
 */
-(void)sendUserNotification {
    
    
    NSString *messageFormat = @"Okay, begin %@!";
    NSString *action = nil;
    NSString *iconName = nil;
    NSString *soundName = nil;
    
    switch (appController.currentActionState) {
        case SDAActionStateSitting:
            action = SITTING_ACTION_TEXT;
            iconName = SITTING_MENU_ICON;
            soundName = appController.settings.sittingSettings.soundFile;
            break;
        case SDAActionStateStanding:
            action = STANDING_ACTION_TEXT;
            iconName = STANDING_MENU_ICON;
            soundName = appController.settings.standingSettings.soundFile;
            break;
        default:
            // If this is an unexpected state, do not
            // send any message
            return;
    }
    
    NSUserNotification *alert = [[NSUserNotification alloc]init];
    alert.title = @"Time to switch it up!";
    alert.subtitle = [NSString stringWithFormat:messageFormat, action];
    alert.soundName = soundName;
    alert.contentImage = [NSImage imageNamed:iconName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:alert];
}

@end
