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

-(NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}
-(int)intMinToSec:(int)minutes {
  return minutes * 60;
}

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
  [self updateActionMenuItem];
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

// Preferences->General
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

// Preferences->Alerts
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

// Preferences Buttons
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

// Main Menu
- (IBAction)onMenuSnooze:(id)sender {
  NSLog(@"Snooze menu item activated!");
}
- (IBAction)onMenuSkip:(id)sender {
  NSLog(@"Skip menu item activated!");
}
- (IBAction)onMenuQuit:(id)sender {
  NSLog(@"%@ quit", appName);
  [[NSApplication sharedApplication] terminate:self];
}

// Private methods
- (void)updateActionMenuItem {
  self.actionMenuItem.title = appController.currentActionState == SDAActionStateStanding ? STANDING_ACTION_TEXT : SITTING_ACTION_TEXT;
}
- (void)updateTimerMenuItem {
  self.timerMenuItem.title = appController.stringFromTimeLeft;
}
@end
