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
#import <MASShortcut/Shortcut.h>

@implementation SDAAppDelegate

SDAAppController* appController;
SDAActionState completedState;
NSString *appName;
NSSound *sitSound;
NSSound *standSound;
NSString *const globalKeyShortcutPause = @"KeyShortcutPause";
NSString *const globalKeyShortcutSkip = @"KeyShortcutSkip";

#pragma mark - Event Handlers
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // hook into sleep/wake events
  [self registerSleepWakeNotifications];

  // initialize global shortcut keys
  [self initKeyboardShortcutKeys];

  appName = NSBundle.mainBundle.infoDictionary  [@"CFBundleName"];
    
  // Setup the basic, basic settings for Preferences on disk
  SDAAppSettings *defaultSettings = [SDAAppSettings defaultSettings];
  [[NSUserDefaults standardUserDefaults] registerDefaults:[defaultSettings toDictionary]];
    
  // Create our brain
  appController = [[SDAAppController alloc]init];
  [appController loadSettings];
  [appController setDelegate:self];
  [appController scheduleSit];
    
  // Hook into the user notification center
  [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id<NSUserNotificationCenterDelegate>)self];

  // Set up main menu
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:_statusMenu];

  NSImage *sitting_menu_icon = [NSImage imageNamed:SITTING_MENU_ICON];
  sitting_menu_icon.template = YES;

  [statusItem setImage:sitting_menu_icon];
  [statusItem setHighlightMode:YES];
  [statusItem setToolTip:appName];
  [_statusMenu setAutoenablesItems:NO];

  // Make menu action/time have disabled text style
  [_actionMenuItem setEnabled:false];
  [_timerMenuItem setEnabled:false];
  [self updateActionMenuItem];

  // Load alert popups with system sounds
  [_prefWindowSitAlertSystemSoundPopUp addItemsWithTitles:[NSSound systemSounds]];
  [_prefWindowSitAlertSystemSoundPopUp insertItemWithTitle:@"" atIndex:0];
  [_prefWindowStandAlertSystemSoundPopUp addItemsWithTitles:[NSSound systemSounds]];
  [_prefWindowStandAlertSystemSoundPopUp insertItemWithTitle:@"" atIndex:0];

  [_prefWindow setDelegate:self];
  [_transWindow setDelegate:self];
  [_prefWindowStandTime setDelegate:self];
  [_prefWindowSitTime setDelegate:self];
  [_prefWindowIdleTime setDelegate:self];
  [_prefWindowSnoozeTime setDelegate:self];

  // Transitioning Window Buttons
  [_transWindow setDefaultButtonCell:[_transWindowContinueBtn cell]];
  [_transWindowContinueBtn setBezelStyle:NSRoundedBezelStyle];
  [_transWindowRestartBtn setBezelStyle:NSRoundedBezelStyle];
  [_transWindowSnoozeBtn setBezelStyle:NSRoundedBezelStyle];
  [_transWindowSkipBtn setBezelStyle:NSRoundedBezelStyle];

  [self loadAppSettingsToPrefUI];

  // Perform first-time actions, if necessary
  [self checkIfFirstTime];
}
- (void)actionPeriodHasStarted:(SDAAppController *)sender {
  /* check the last completed state */
  /* if it's sitting, then we schedule a stand */
  /* else we schedule a sit */
  if (completedState == SDAActionStateStanding) {
    [appController scheduleSit];
  }
  else {
    [appController scheduleStand];
  }

  /* update menu text */
  /* send a notification */
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
  [self sendSitStandNotification];
}
- (void)actionPeriodDidComplete:(SDAAppController *)sender actionCompleted:(SDAActionState)state {
  /* record the completed state */
  completedState = state;
  /* set application to new transitioning state */
  [appController scheduleTransition];
  /* notify the user that a new event is about to start */
  [self sendNotificationForTransitioning];
  /* update menu item */
  [self updateActionMenuItem];
}
- (void)runningTickDidOccur:(SDAAppController *)sender {
  [self updateTimerMenuItem];
}
- (void)appDidPauseForIdle:(SDAAppController *)sender {
  [self updateActionMenuItem];
}
- (void)appDidResumeFromIdle:(SDAAppController *)sender {
  // Actions to occur when user breaks system idle state
  NSString *action = nil;
  if(appController.currentActionState == SDAActionStateSitting) {
      action = SITTING_ACTION_TEXT;
  } else if (appController.currentActionState == SDAActionStateStanding) {
      action = STANDING_ACTION_TEXT;
  }
    
  if(action) {
    NSString *msg = [NSString stringWithFormat:RESUME_TEXT_FORMAT, [action lowercaseString]];
    [self sendNotificationWithTitle:RESUME_TEXT_TITLE
                                msg:msg
                          soundFile:nil
                           iconFile:nil];
  }
  [self updateActionMenuItem];
}
- (void)controlTextDidEndEditing:(NSNotification *)obj {
  NSTextField* textField = (NSTextField *)[obj object];
  if ([[textField stringValue] isEqualToString:@""]) {
    [textField setStringValue:@"1"];
  }
}
- (void)receiveSleepNote:(NSNotification*)note {
  //NSLog(@"receiveSleepNote: %@", [note name]);
  [appController pauseTimer];
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
}
- (void)receiveWakeNote:(NSNotification*)note {
  //NSLog(@"receiveWakeNote: %@", [note name]);
  [appController resumeTimer];
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
}
- (void)registerSleepWakeNotifications {
  //These notifications are filed on NSWorkspace's notification center, not the default
  // notification center. You will not receive sleep/wake notifications if you file
  //with the default notification center.
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                         selector: @selector(receiveSleepNote:)
                                                             name: NSWorkspaceWillSleepNotification object: NULL];

  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                         selector: @selector(receiveWakeNote:)
                                                             name: NSWorkspaceDidWakeNotification object: NULL];
}

#pragma mark - Menu Item Actions
- (IBAction)onMenuRestart:(id)sender {
  SDAActionState state = appController.currentActionState;
  if (state == SDAActionStateTransitioning) state = appController.lastCompletedActionState;
  if (state == SDAActionStateStanding) {
    [appController scheduleStand];
  } else if (state == SDAActionStateSitting){
    [appController scheduleSit];
  }
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
  [self updateResumePauseMenuItem];
}
- (IBAction)onMenuPause:(id)sender {
  if (appController.currentStatus == SDAStatusRunning) {
    [appController pauseTimer];
  }
  else if (appController.currentStatus == SDAStatusPaused) {
    [appController resumeTimer];
  }
  [self updateResumePauseMenuItem];
  [self updateActionMenuItem];
}
- (IBAction)onMenuSnooze:(id)sender {
  [appController snooze];
  [self updateResumePauseMenuItem];
  [self updateActionMenuItem];
}
- (IBAction)onMenuSkip:(id)sender {
  [appController skipToNext];
  [self sendSitStandNotification];
  [self updateResumePauseMenuItem];
  [self updateActionMenuItem];
}
- (IBAction)onMenuAbout:(id)sender {
  [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
  [NSApp activateIgnoringOtherApps:true];
}
- (IBAction)onMenuPref:(id)sender {
  [self openPrefsWindow];
}
- (IBAction)onMenuQuit:(id)sender {
  //NSLog(@"%@ quit", appName);
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - Preferences->General Actions
- (IBAction)onStandIntervalChange:(id)sender {
  [_prefWindowPresetPopUp setTitle:@"Custom"];
  NSString *preset = [[_prefWindowPresetPopUp selectedItem] title];
  appController.settings.currentPreset = preset;

  appController.settings.standingInterval = [self intMinToSec:(int)_prefWindowStandTime.integerValue];

  [appController saveSettings];
}
- (IBAction)onSitIntervalChange:(id)sender {
  [_prefWindowPresetPopUp setTitle:@"Custom"];
  NSString *preset = [[_prefWindowPresetPopUp selectedItem] title];
  appController.settings.currentPreset = preset;

  appController.settings.sittingInterval = [self intMinToSec:(int)_prefWindowSitTime.integerValue];

  [appController saveSettings];
}
- (IBAction)onIntervalApplyPressed:(id)sender {
  SDAActionState state = appController.currentActionState;
  if (state == SDAActionStateTransitioning) state = appController.lastCompletedActionState;
  if (state == SDAActionStateStanding) {
    [appController scheduleStand];
  } else if (state == SDAActionStateSitting){
    [appController scheduleSit];
  }
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
  [self updateResumePauseMenuItem];
}
- (IBAction)onPresetChange:(id)sender {
  NSString *preset = [[_prefWindowPresetPopUp selectedItem] title];

  appController.settings.currentPreset = preset;
  [_prefWindowStandTime setStringValue:[self stringSecToMin:[appController.settings standIntervalForPreset:preset]]];
  [_prefWindowSitTime setStringValue:[self stringSecToMin:[appController.settings sitIntervalForPreset:preset]]];

  [appController saveSettings];
}
- (IBAction)onIdleTimeTextFieldChange:(id)sender {
  appController.settings.idlePauseTime = [self intMinToSec:[sender intValue]];
  [appController saveSettings];
}
- (IBAction)onSnoozeTimeTextFieldChange:(id)sender {
  appController.settings.snoozeTime = [self intMinToSec:[sender intValue]];
  [appController saveSettings];
}
- (IBAction)onLoginToggleChange:(id)sender {
  if ([_prefWindowLoginToggle state] == NSOnState)
  {
    appController.settings.isLoginItem = true;
    [self addAppAsLoginItem];
  } else if ([_prefWindowLoginToggle state] == NSOffState) {
    appController.settings.isLoginItem = false;
    [self deleteAppFromLoginItem];
  }
  [appController saveSettings];
}

#pragma mark - Preferences->Alerts Actions
// Stand
- (IBAction)onStandAlertSystemSoundPopUpChange:(id)sender {
  NSString* newAudioFilePath = [[_prefWindowStandAlertSystemSoundPopUp selectedItem] title];
  standSound = [self updateSoundFile:newAudioFilePath];
  appController.settings.standingSettings.soundFile = newAudioFilePath;
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound stop];
  [standSound play];
  [appController saveSettings];
}
- (IBAction)onStandAlertVolumeChange:(id)sender {
  appController.settings.standingSettings.volume = [_prefWindowStandVolume floatValue];
  [standSound setVolume:appController.settings.standingSettings.volume];
  [standSound stop];
  [standSound play];
  [appController saveSettings];
}

// Sit
- (IBAction)onSitAlertSystemSoundPopUpChange:(id)sender {
  NSString* newAudioFilePath = [[_prefWindowSitAlertSystemSoundPopUp selectedItem] title];
  sitSound = [self updateSoundFile:newAudioFilePath];
  appController.settings.sittingSettings.soundFile = newAudioFilePath;
  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [sitSound stop];
  [sitSound play];
  [appController saveSettings];
}
- (IBAction)onSitAlertVolumeChange:(id)sender {
  appController.settings.sittingSettings.volume = [_prefWindowSitVolume floatValue];
  [sitSound setVolume:appController.settings.sittingSettings.volume];
  [sitSound stop];
  [sitSound play];
  [appController saveSettings];
}

#pragma mark - Transitioning Window Actions
- (IBAction)onTransContinue:(id)sender {
  [appController resumeTimer];
  [_transWindow performClose:self];
}
- (IBAction)onTransRestart:(id)sender {
  SDAActionState state = appController.currentActionState;
  if (state == SDAActionStateTransitioning) state = appController.lastCompletedActionState;
  if (state == SDAActionStateStanding) {
    [appController scheduleStand];
  } else if (state == SDAActionStateSitting){
    [appController scheduleSit];
  }
  [self updateActionMenuItem];
  [self updateTimerMenuItem];
  [self updateResumePauseMenuItem];
  [_transWindow performClose:self];
}
- (IBAction)onTransSnooze:(id)sender {
  [appController snooze];
  [self updateResumePauseMenuItem];
  [self updateActionMenuItem];
  [_transWindow performClose:self];
}
- (IBAction)onTransSkip:(id)sender {
  [appController skipToNext];
  [self sendSitStandNotification];
  [self updateResumePauseMenuItem];
  [self updateActionMenuItem];
  [_transWindow performClose:self];
}

#pragma mark - Private methods
- (void)openPrefsWindow {
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [_prefWindow makeKeyAndOrderFront:self];
}
- (void)openTransWindow {
  [_transWindowLastCompletedAction setStringValue:appController.lastCompletedActionState == SDAActionStateStanding ? @"Standing" : @"Sitting"];
  [_transWindowNextActionToStart setStringValue:appController.lastCompletedActionState == SDAActionStateStanding ? @"Sitting" : @"Standing"];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [_transWindow center];
  [_transWindow makeKeyAndOrderFront:self];
}

/* Converts seconds to minutes as a string to place into UI text fields. */
- (NSString*)stringSecToMin:(int)seconds {
  return [NSString stringWithFormat:@"%d", seconds / 60];
}

/* Converts minutes to seconds to add to app settings. */
- (int)intMinToSec:(int)minutes {
  return minutes * 60;
}

/* Updates the main menu status and timer */
- (void)updateActionMenuItem {
  NSImage *sitting_menu_icon = [NSImage imageNamed:SITTING_MENU_ICON];
  sitting_menu_icon.template = YES;
  NSImage *standing_menu_icon = [NSImage imageNamed:STANDING_MENU_ICON];
  standing_menu_icon.template = YES;
  NSImage *transitioning_menu_icon = [NSImage imageNamed:TRANSITIONING_MENU_ICON];
  transitioning_menu_icon.template = YES;
  NSImage *paused_menu_icon = [NSImage imageNamed:PAUSED_MENU_ICON];
  //paused_menu_icon.template = YES;

  switch (appController.currentActionState) {
    case SDAActionStateTransitioning:
      self.actionMenuItem.title = TRANSITIONING_ACTION_TEXT;
      [statusItem setImage:transitioning_menu_icon];
      break;
    case SDAActionStateSitting:
      self.actionMenuItem.title = SITTING_ACTION_TEXT;
      [statusItem setImage:sitting_menu_icon];
      break;
    case SDAActionStateStanding:
      self.actionMenuItem.title = STANDING_ACTION_TEXT;
      [statusItem setImage:standing_menu_icon];
      break;
    case SDAActionStateNone:
      self.actionMenuItem.title = ERROR_STATUS_TEXT;
      break;
    default:
      self.actionMenuItem.title = @"";
      break;
  }
  if (appController.currentStatus == SDAStatusPaused || appController.currentStatus == SDAStatusIdle)
  {
    self.actionMenuItem.title = PAUSED_ACTION_TEXT;
    [statusItem setImage:paused_menu_icon];
  }
}
- (void)updateTimerMenuItem {
  self.timerMenuItem.title = appController.stringFromTimeLeft;
}
- (void)updateResumePauseMenuItem {
  if (appController.currentStatus == SDAStatusRunning) {
    [_pauseMenuItem setTitle:NSLocalizedString(@"Pause", nil)];
  }
  else if (appController.currentStatus == SDAStatusPaused) {
    [_pauseMenuItem setTitle:NSLocalizedString(@"Resume", nil)];
  }
}

/* Load local appsettings values
   into Preferences Window UI */
- (void)loadAppSettingsToPrefUI {
  // Preferences->General
  [_prefWindowPresetPopUp setTitle:appController.settings.currentPreset];
  [_prefWindowStandTime setStringValue:[self stringSecToMin:appController.settings.standingInterval]];
  [_prefWindowSitTime setStringValue:[self stringSecToMin:appController.settings.sittingInterval]];
  [_prefWindowIdleTime setStringValue:[self stringSecToMin:appController.settings.idlePauseTime]];
  [_prefWindowSnoozeTime setStringValue:[self stringSecToMin:appController.settings.snoozeTime]];
  _prefWindowLoginToggle.state = appController.settings.isLoginItem ? NSOnState : NSOffState;

  // Preferences->Alerts
  // Stand
  NSString* standSoundFilePath = appController.settings.standingSettings.soundFile;
  [_prefWindowStandAlertSystemSoundPopUp selectItemWithTitle:standSoundFilePath];
  standSound = [self updateSoundFile:standSoundFilePath];
  [_prefWindowStandVolume setFloatValue:appController.settings.standingSettings.volume];

  // Sit
  NSString* sitSoundFilePath = appController.settings.sittingSettings.soundFile;
  [_prefWindowSitAlertSystemSoundPopUp selectItemWithTitle:sitSoundFilePath];
  sitSound = [self updateSoundFile:sitSoundFilePath];
  [_prefWindowSitVolume setFloatValue:appController.settings.sittingSettings.volume];
}

/* Plays a sound for the current action state. */
- (void)playSounds {
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

/* Loads a new sound file into the global sound file variable */
- (NSSound*)updateSoundFile:(NSString*)audioFilePath {
  NSSound* audioFile;
  if (audioFilePath) {
    audioFile = [NSSound soundNamed:audioFilePath];
    return audioFile;
  } else {
    //NSLog(@"audioFilePath nil or blank");
    return nil;
  }
}

/* Sends a notification alert to the OSX Notification
   indicating the current status and action a user should take. */
- (void)sendSitStandNotification {
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
    case SDAActionStateTransitioning:
      action = TRANSITIONING_ACTION_TEXT;
      iconName = completedState == SDAActionStateSitting ? SITTING_NOTIFICATION_ICON : STANDING_NOTIFICATION_ICON;
      soundName = @"Funk";
      break;
    default:
      // If this is an unexpected state, do not
      // send any message
      return;
  }

  [self sendNotificationWithTitle:[NSString stringWithFormat:NOTIFY_USER_TITLE, action] msg:[NSString stringWithFormat:NOTIFY_USER_FORMAT, [action lowercaseString]] soundFile:soundName iconFile:iconName];
}
- (void)sendNotificationWithTitle:(NSString*)title msg:(NSString*)msg soundFile:(NSString*)soundFile iconFile:(NSString*)iconName {
  NSUserNotification *alert = [[NSUserNotification alloc]init];
  alert.title = title;
  alert.subtitle = msg;

  // NSUserNotification won't play custom sounds in bundle and/or not in system sounds directories,
  // so we play a sound after the notification is displayed, getting around that
  NSUserNotificationCenter *userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
  [userNotificationCenter removeAllDeliveredNotifications];
  [userNotificationCenter deliverNotification:alert];
  [self playSounds];
}
- (void)sendNotificationForTransitioning {
  [self sendNotificationWithTitle:TRANSITIONING_ACTION_TEXT msg:[NSString stringWithFormat:NSLocalizedString(@"Time to get ready to %@!", nil), appController.lastCompletedActionState == SDAActionStateSitting ? NSLocalizedString(@"stand", nil) : NSLocalizedString(@"sit", nil)] soundFile:nil iconFile:nil];
}

/* Adds and removes app from current user's
   Login Items depending on app setting checkbox */
- (void)addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];

	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];

	// Create a reference to the shared file list.
  // We are adding it to the current user only.
  // If we want to add it all users, use
  // kLSSharedFileListGlobalLoginItems instead of
  //  kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                          kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                 kLSSharedFileListItemLast, NULL, NULL,
                                                                 url, NULL, NULL);
		if (item) {
			CFRelease(item);
    }
	}

	CFRelease(loginItems);
}
- (void)deleteAppFromLoginItem {
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
			if (LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

/* Checks to see if the application has been run before.
   If not, opens the preferences window to allow user to 
   set initial settings. */
- (void)checkIfFirstTime {
  if(appController.settings.isFirstTimeRunning) {
    appController.settings.isFirstTimeRunning = NO;
        
    // Okay to save settings, this should be called first, and only once ever.
    [appController saveSettings];
        
    // Then bring up the preferences window to allow the
    // user to modify initial states
    [self openPrefsWindow];
  }
}

/* Event Elapsed Notification is Clicked */
- (void)transNotificationClicked {
  SDAActionState state = appController.currentActionState;
  if (state == SDAActionStateTransitioning) {
    [appController pauseTimer];
    [self openTransWindow];
  }
  //NSLog(@"notification clicked");
}

/* Global Keyboard Shortcut Init */
- (void)initKeyboardShortcutKeys {
  // Assign the preference key and the shortcut view will take care of persistence
  self.shortcutViewPause.associatedUserDefaultsKey = globalKeyShortcutPause;
  self.shortcutViewSkip.associatedUserDefaultsKey = globalKeyShortcutSkip;

  // pause/resume
  [[MASShortcutBinder sharedBinder]
    bindShortcutWithDefaultsKey:globalKeyShortcutPause
    toAction:^{
    if (appController.currentStatus == SDAStatusRunning) {
      [appController pauseTimer];
    }
    else if (appController.currentStatus == SDAStatusPaused) {
      [appController resumeTimer];
    }
    [self updateResumePauseMenuItem];
    [self updateActionMenuItem];
  }];

  // skip
  [[MASShortcutBinder sharedBinder]
    bindShortcutWithDefaultsKey:globalKeyShortcutSkip
    toAction:^{
    [appController skipToNext];
    [self sendSitStandNotification];
    [self updateResumePauseMenuItem];
    [self updateActionMenuItem];
  }];
}

@end
