//
//  SDAAppDelegate+Notifications.m
//  Standing Desk App
//
//  Created by David Vera on 1/5/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import "SDAAppDelegate+Notifications.h"

@implementation SDAAppDelegate (Notifications)

/* NSUserNotificationCenterDelegate: Occurs when user notification has been clicked by user. */
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    
  [self openEventOptionsWindow];
}

/* NSUserNotificationCenterDelegate: Occurs when notification
  center decides NOT to show a notification. Overridden to force
  application to always show alert. */
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    
    // Returning YES will force the notification to show
    // appear to the user, regardless of whether the application
    // is in the foreground (main) or in focus (key)
    return YES;
}
@end
