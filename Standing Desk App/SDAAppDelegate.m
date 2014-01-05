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

#pragma mark - Event Handlers
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  appName = NSBundle.mainBundle.infoDictionary  [@"CFBundleName"];
  appController = [[SDAAppController alloc]init];
  [appController loadSettings];
  [appController setDelegate:self];
  [appController scheduleSit];

  /* set up main menu */
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:_statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"logo64x64.png"]];
  [statusItem setHighlightMode:YES];
  [statusItem setToolTip:appName];
  [_statusMenu setAutoenablesItems:NO];

  [_actionMenuItem setEnabled:false];
  [self updateActionMenuItem];
  [_timerMenuItem setEnabled:false];

  /* Load alert comboboxes with system sounds */
  [_prefWindowSitAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];
  [_prefWindowStandAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];

  [_prefWindow setDelegate:self];
}

- (void)actionPeriodDidComplete:(SDAAppController *)sender actionState:(SDAActionState)status {
  [self playSounds];
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
  // Preferences->General
  [_prefWindowStandTime setStringValue:[self stringSecToMin:appController.settings.standingInterval]];
  [_prefWindowSitTime setStringValue:[self stringSecToMin:appController.settings.sittingInterval]];
  [_prefWindowIdleTime setStringValue:[self stringSecToMin:appController.settings.idlePauseTime]];
  [_prefWindowSnoozeTime setStringValue:[self stringSecToMin:appController.settings.snoozeTime]];

  // Preferences->Alerts
  [_prefWindowSitAlertComboBox setStringValue:appController.settings.sittingSettings.soundFile];
  [_prefWindowSitVolume setFloatValue:appController.settings.sittingSettings.volume];
  _prefWindowSitVolumeMute.state = appController.settings.sittingSettings.isMute ? NSOnState : NSOffState;
  [_prefWindowStandAlertComboBox setStringValue:appController.settings.standingSettings.soundFile];
  [_prefWindowStandVolume setFloatValue:appController.settings.standingSettings.volume];
  _prefWindowStandVolumeMute.state = appController.settings.standingSettings.isMute ? NSOnState : NSOffState;
}

#pragma mark - Preferences->General
- (IBAction)onStandTimeComboBoxChange:(id)sender {
  appController.settings.standingInterval = [self intMinToSec:_prefWindowStandTime.integerValue];
}
- (IBAction)onSitTimeComboBoxChange:(id)sender {
  appController.settings.sittingInterval = [self intMinToSec:_prefWindowSitTime.integerValue];
}
- (IBAction)onIdleTimeComboBoxChange:(id)sender {
  appController.settings.idlePauseTime = [self intMinToSec:_prefWindowIdleTime.integerValue];
}
- (IBAction)onSnoozeTimeComboBoxChange:(id)sender {
  appController.settings.snoozeTime = [self intMinToSec:_prefWindowSnoozeTime.integerValue];
}

#pragma mark - Preferences->Alerts
- (IBAction)onSitAlertComboBoxChange:(id)sender {
  [[NSSound soundNamed:[sender stringValue]] play];
  appController.settings.sittingSettings.soundFile = [sender stringValue];
}
- (IBAction)onSitAlertVolumeChange:(id)sender {
  appController.settings.sittingSettings.volume = [sender floatValue];
}
- (IBAction)onSitAlertMuteChange:(id)sender {
  appController.settings.sittingSettings.isMute = [sender state] == NSOnState;
}
- (IBAction)onStandAlertComboBoxChange:(id)sender {
  [[NSSound soundNamed:[sender stringValue]] play];
  appController.settings.standingSettings.soundFile = [sender stringValue];
}
- (IBAction)onStandAlertVolumeChange:(id)sender {
  appController.settings.standingSettings.volume = [sender floatValue];
}
- (IBAction)onStandAlertMuteChange:(id)sender {
  appController.settings.standingSettings.isMute = [sender state] == NSOnState;
}

#pragma mark - Preferences->Buttons
- (IBAction)onPrefGeneralCancel:(id)sender {
  [appController loadSettings];
  [_prefWindow performClose:self];
}
- (IBAction)onPrefGeneralSave:(id)sender {
  [appController saveSettings];
  [_prefWindow performClose:self];
}

- (IBAction)onPrefAlertsCancel:(id)sender {
  [appController loadSettings];
  [_prefWindow performClose:self];
}
- (IBAction)onPrefAlertsSave:(id)sender {
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
- (NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}
- (int)intMinToSec:(int)minutes {
  return minutes * 60;
}
- (void)updateActionMenuItem {
  switch (appController.currentActionState) {
    case SDAActionStateSitting:
      self.actionMenuItem.title = SITTING_ACTION_TEXT;
      break;
    case SDAActionStateStanding:
      self.actionMenuItem.title = STANDING_ACTION_TEXT;
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
- (void)playSounds {
  switch (appController.currentActionState) {
    case SDAActionStateSitting:
      [[NSSound soundNamed:appController.settings.sittingSettings.soundFile] play];
      break;
    case SDAActionStateStanding:
      [[NSSound soundNamed:appController.settings.standingSettings.soundFile] play];
      break;
    default:
      break;
  }
}

@end
