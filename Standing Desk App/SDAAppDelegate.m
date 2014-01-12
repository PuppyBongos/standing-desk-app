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
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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

  // Preferences Buttons
  [_prefWindowCancelBtn setBezelStyle:NSRoundedBezelStyle];
  [_prefWindow setDefaultButtonCell:[_prefWindowSaveBtn cell]];
  [_prefWindowSaveBtn setBezelStyle:NSRoundedBezelStyle];

    // Perform first-time actions, if necessary
  [self checkIfFirstTime];
}

- (void)actionPeriodDidComplete:(SDAAppController *)sender actionState:(SDAActionState)status {
  
  if (appController.currentActionState == SDAActionStateStanding) {
    [appController scheduleSit];
  }
  else {
    [appController scheduleStand];
  }
    
    [self updateActionMenuItem];
    [self sendSitStandNotification];
}

- (void)runningTickDidOccur:(SDAAppController *)sender {
  [self updateTimerMenuItem];
}

- (void)appDidPauseForIdle:(SDAAppController *)sender {
    // Actions to occur when system idle threshold is met
}

-(void)appDidResumeFromIdle:(SDAAppController *)sender {
    
    // Actions to occur when user breaks system idle state
    NSString *action = nil;
    if(appController.currentActionState == SDAActionStateSitting) {
        action = SITTING_ACTION_TEXT;
    } else if (appController.currentActionState == SDAActionStateStanding) {
        action = STANDING_ACTION_TEXT;
    }
    
    if(action) {
        
        NSString *msg = [NSString stringWithFormat:RESUME_TEXT_FORMAT,
                         action];
        [self sendNotificationWithTitle:RESUME_TEXT_TITLE
                                    msg:msg
                              soundFile:nil
                               iconFile:nil];
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    // Preferences Buttons
    // Meant to force 'Save' button to behave as
    // default. Fixed in xib.
    /*
    [_prefWindowSaveBtn setBezelStyle:NSRoundedBezelStyle];
    [_prefWindow setDefaultButtonCell:[_prefWindowSaveBtn cell]];
    [_prefWindowSaveBtn setKeyEquivalent:@"\r"];
    [_prefWindowSaveBtn setNeedsDisplay:YES];
   */
    
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

  // Preferences->Login
  _prefWindowLoginToggle.state = appController.settings.isLoginItem ? NSOnState : NSOffState;
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
  [sitSound stop];
  [sitSound play];
}
- (IBAction)onSitAlertVolumeChange:(id)sender {
  sitSound = [NSSound soundNamed:[_prefWindowSitAlertComboBox stringValue]];
  appController.settings.sittingSettings.volume = [_prefWindowSitVolume floatValue];
  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [sitSound stop];
  [sitSound play];
}
- (IBAction)onStandAlertComboBoxChange:(id)sender {
  standSound = [NSSound soundNamed:[_prefWindowStandAlertComboBox stringValue]];
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound stop];
  [standSound play];
}
- (IBAction)onStandAlertVolumeChange:(id)sender {
  standSound = [NSSound soundNamed:[_prefWindowStandAlertComboBox stringValue]];
  appController.settings.standingSettings.volume = [_prefWindowStandVolume floatValue];
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound stop];
  [standSound play];
}

#pragma mark - Preferences->Login
- (IBAction)onLoginToggleChange:(id)sender {

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
- (IBAction)onMenuPref:(id)sender {
    [self openPrefsWindow];
}
- (IBAction)onMenuQuit:(id)sender {
  NSLog(@"%@ quit", appName);
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Menu Item private methods

/**
 * Opens the Preferences window over all other windows.
 */
-(void)openPrefsWindow {
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [_prefWindow makeKeyAndOrderFront:self];
}

/** 
 * Convenience method that converts seconds to minutes 
 * as a string to place into UI text fields.
 */
- (NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}

/**
 * Convenience method that converts minutes to seconds
 * to add to app settings.
 */
- (int)intMinToSec:(int)minutes {
  return minutes * 60;
}

/**
 * Updates the main menu status and timer
 */
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

  if ([_prefWindowLoginToggle state] == NSOnState)
  {
    appController.settings.isLoginItem = true;
    [self addAppAsLoginItem];
  } else if ([_prefWindowLoginToggle state] == NSOffState) {
    appController.settings.isLoginItem = false;
    [self deleteAppFromLoginItem];
  }
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
-(void)sendSitStandNotification {

    NSString *action = nil;
    NSString *iconName = nil;
    NSString *soundName = nil;
    
    switch (appController.currentActionState) {
        case SDAActionStateSitting:
            action = SITTING_ACTION_TEXT;
            iconName = SITTING_NOTIFICATION_ICON;
            soundName = appController.settings.sittingSettings.soundFile;
            break;
        case SDAActionStateStanding:
            action = STANDING_ACTION_TEXT;
            iconName = STANDING_NOTIFICATION_ICON;
            soundName = appController.settings.standingSettings.soundFile;
            break;
        default:
            // If this is an unexpected state, do not
            // send any message
            return;
    }

  [self sendNotificationWithTitle:NOTIFY_USER_TITLE msg:[NSString stringWithFormat:NOTIFY_USER_FORMAT, action] soundFile:soundName iconFile:iconName];
}

-(void)sendNotificationWithTitle:(NSString*)title msg:(NSString*)msg soundFile:(NSString*)soundFile iconFile:(NSString*)iconName {
  NSUserNotification *alert = [[NSUserNotification alloc]init];
  alert.title = title;
  alert.subtitle = msg;
  alert.soundName = soundFile;
  alert.contentImage = [NSImage imageNamed:iconName];
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:alert];

}

/**
 *  Adds and removes app from current user's
    Login Items depending on app setting checkbox
 */
-(void)addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];

	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];

	// Create a reference to the shared file list.
  // We are adding it to the current user only.
  // If we want to add it all users, use
  // kLSSharedFileListGlobalLoginItems instead of
  //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                          kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                 kLSSharedFileListItemLast, NULL, NULL,
                                                                 url, NULL, NULL);
		if (item){
			CFRelease(item);
    }
	}

	CFRelease(loginItems);
}
-(void)deleteAppFromLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];

	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);

	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                          kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		for(int i = 0; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                  objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

/** Checks to see if the application has been run before. If not,
 opens the preferences window to allow user to set initial settings. */
-(void)checkIfFirstTime {
    
    if(appController.settings.isFirstTimeRunning) {
        appController.settings.isFirstTimeRunning = NO;
        
        // Okay to save settings, this should be called first, and only once ever.
        [appController saveSettings];
        
        // Then bring up the preferences window to allow the
        // user to modify initial states
        [self openPrefsWindow];
    }
}
@end
