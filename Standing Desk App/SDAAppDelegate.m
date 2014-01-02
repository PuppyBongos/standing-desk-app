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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  appController = [[SDAAppController alloc]init];
  [appController loadSettings];

  [_statusMenu setAutoenablesItems:NO];

  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:_statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"icon16.png"]];
  [statusItem setHighlightMode:YES];
  [statusItem setToolTip:@"Standing Desk App"];

  [prefWindow setDelegate:self];

}

@end
