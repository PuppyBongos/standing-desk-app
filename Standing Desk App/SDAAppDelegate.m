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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  appName = NSBundle.mainBundle.infoDictionary  [@"CFBundleName"];
  appController = [[SDAAppController alloc]init];
  [appController loadSettings];

  [_statusMenu setAutoenablesItems:NO];

  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:_statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"icon16.png"]];
  [statusItem setHighlightMode:YES];
  [statusItem setToolTip:appName];

  /* Load alert comboboxes with system sounds */
  [_prefWindowSitAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];
  [_prefWindowStandAlertComboBox addItemsWithObjectValues:[NSSound systemSounds]];

  [_prefWindow setDelegate:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  NSLog(@"Preferences window activated");
  [_prefWindowStandTime setStringValue:[self stringSecToMin:appController.settings.standingInterval]];
}

-(NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}

// Preferences->General
- (IBAction)onStandTimeComboBoxChange:(id)sender {
  appController.settings.standingInterval = (_prefWindowStandTime.integerValue * 60);
}
- (IBAction)onSitTimeComboBoxChange:(id)sender {
  appController.settings.sittingInterval = _prefWindowSitTime.integerValue;
}
- (IBAction)onIdleTimeComboBoxChange:(id)sender {
  appController.settings.idlePauseTime = _prefWindowIdleTime.integerValue;
}
- (IBAction)onSnoozeTimeComboBoxChange:(id)sender {
  appController.settings.snoozeTime = _prefWindowSnoozeTime.integerValue;
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
  appController.settings.sittingSettings.isMute = [sender boolValue];
}
- (IBAction)onStandAlertComboBoxChange:(id)sender {
  [[NSSound soundNamed:[sender stringValue]] play];
  appController.settings.standingSettings.soundFile = [sender stringValue];
}
- (IBAction)onStandAlertVolumeChange:(id)sender {
  appController.settings.standingSettings.volume = [sender floatValue];
}
- (IBAction)onStandAlertMuteChange:(id)sender {
  appController.settings.standingSettings.isMute = [sender boolValue];
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

@end
