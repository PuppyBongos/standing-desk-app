//
//  SDAAppDelegate.m
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppDelegate.h"
#import "SDAAppController.h"

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

  [_prefWindow setDelegate:self];

}
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
- (IBAction)onPrefCancel:(id)sender {
  [_prefWindow performClose:self];
}

@end
