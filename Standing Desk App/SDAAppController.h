//
//  SDAAppController.h
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAAppSettings.h"

#pragma mark - Type definitions
enum SDAStatus {
    SDAStatusPaused     = 0,
    SDAStatusIdle       = 1,
    SDAStatusRunning    = 2,
    SDAStatusWaiting    = 3,
} typedef SDAStatus;

enum SDAActionState {
    SDAActionStateNone      = 0,
    SDAActionStateStanding  = 1,
    SDAActionStateSitting   = 2
} typedef SDAActionState;

#pragma mark - SDAApplicationDelegate
@protocol SDAApplicationDelegate <NSObject>

@required
/* Occurs when the interval for an action state (sitting or standing) has elapsed. */
-(void)actionPeriodDidComplete:(id)sender actionState:(SDAActionState)status;

@end


#pragma mark - SDAAppController
@interface SDAAppController : NSObject {
    
    // State time amount between time intervals
    NSTimeInterval _currentTimeLeft;
    
    SDAActionState _actionState;
    SDAStatus _currentStatus;
}

@property (readonly) SDAActionState currentActionState;

@property (readonly) SDAStatus currentStatus;

/* Settings for the Standing Desk App  */
@property (strong) SDAAppSettings* settings;

@property (readonly) NSTimeInterval currentTimeLeft;

@property (strong) id<SDAApplicationDelegate> delegate;

/* Saves the current settings to disk */
-(void)saveSettings;

/* Reloads the settings from disk */
-(void)loadSettings;

/* Starts a period of sitting */
-(void)scheduleSit;

/* Starts a period of standing */
-(void)scheduleStand;

/* Adds a snooze period to the current period's time and resumes the current action period. */
-(void)snooze;

/* Skips to the next period state if running, or repeats the state if the controller is waiting. */
-(void)skipToNext;

/* Suspends the timer period countdown */
-(void)pauseTimer;

/* Resumes the timer period countdown, if any time is left. */
-(void)resumeTimer;

-(NSString*)stringFromTimeLeft;
@end
