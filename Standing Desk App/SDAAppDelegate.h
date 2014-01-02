//
//  SDAAppDelegate.h
//  Standing Desk App
//
//  Created by Michael Chadwick on 12/17/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDAAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

{
  NSStatusItem* statusItem;
}

@property (assign) IBOutlet NSWindow *prefWindow;
@property (weak) IBOutlet NSComboBox *prefWindowStandTime;
@property (weak) IBOutlet NSComboBox *prefWindowSitTime;
@property (weak) IBOutlet NSComboBox *prefWindowPauseTime;
@property (weak) IBOutlet NSButton *prefWindowCancelBtn;
@property (weak) IBOutlet NSButton *prefWindowSaveBtn;
@property (weak) IBOutlet NSComboBox *prefWindowSitAlertComboBox;
@property (weak) IBOutlet NSSlider *prefWindowSitVolume;
@property (weak) IBOutlet NSButton *prefWindowSitVolumeMute;
@property (weak) IBOutlet NSComboBox *prefWindowStandAlertComboBox;
@property (weak) IBOutlet NSSlider *prefWindowStandVolume;
@property (weak) IBOutlet NSButton *prefWindowStandVolumeMute;

@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *snoozeMenuItem;
@property (weak) IBOutlet NSMenuItem *skipMenuItem;
@property (weak) IBOutlet NSMenuItem *prefMenuItem;
@property (weak) IBOutlet NSMenuItem *quitMenuItem;

@end
