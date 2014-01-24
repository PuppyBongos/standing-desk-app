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
    SDAStatusStopped    = 3,
} typedef SDAStatus;

enum SDAActionState {
    SDAActionStateNone          = 0,
    SDAActionStateStanding      = 1,
    SDAActionStateSitting       = 2,
    SDAActionStateTransitioning = 3,
} typedef SDAActionState;

@class SDAAppController;

#pragma mark - SDAApplicationDelegate
@protocol SDAApplicationDelegate <NSObject>

@optional
/**
  * Occurs at every tick of an active running period. 
 */
-(void)runningTickDidOccur:(SDAAppController*)sender;

/** 
  *   Occurs when the system has been idle longer than the user Idle setting timeout threshold. 
 */
-(void)appDidPauseForIdle:(SDAAppController*)sender;

/**
 *   Occurs when the user has awaken the system during the application's idle state.
 */
-(void)appDidResumeFromIdle:(SDAAppController*)sender;

@required
/**
  * Occurs when the interval for an action state (sitting or standing) has elapsed.
 */
-(void)actionPeriodDidComplete:(SDAAppController*)sender actionCompleted:(SDAActionState)state;

/**
 *  Occurs when the interval for an action state
 (sitting or standing) has started.
 */
-(void)actionPeriodHasStarted:(SDAAppController*)sender;

@end


#pragma mark - SDAAppController
@interface SDAAppController : NSObject {
    
    // State time amount between time intervals
    NSTimeInterval _currentTimeLeft;
    NSTimeInterval _lastUpdateTime;
    
    SDAActionState _actionState;
    SDAStatus _currentStatus;
}

#pragma mark - Properties

/** Gets the last completed state (standing/sitting) of the app
 */
@property (readonly) SDAActionState lastCompletedActionState;

/** Gets the current action state (standing/sitting/transitioning) of the app
 */
@property (readonly) SDAActionState currentActionState;

/**
 * Gets the current status (running/waiting/idle) of the app
 */
@property (readonly) SDAStatus currentStatus;

/**
 * Sets or gets the settings for the Standing Desk App
 */
@property (strong) SDAAppSettings* settings;

/**
  * Gets the amount of time left until the next sit/stand event.
 */
@property (readonly) NSTimeInterval currentTimeLeft;

/**
 * Sets or gets the delegate subscribing to this controller's events.
 */
@property (strong) id<SDAApplicationDelegate> delegate;

#pragma mark - Operations
/**
 * Saves the current settings to disk 
 */
-(void)saveSettings;

/**
 * Reloads the settings from disk
 */
-(void)loadSettings;

/**
 * Starts a period of sitting 
 */
-(void)scheduleSit;

/**
 * Starts a period of standing
 */
-(void)scheduleStand;

/**
 * Starts a period of transitioning
 */
-(void)scheduleTransition;

/**
  * Adds a snooze period to the current period's time and resumes the current action period. 
 */
-(void)snooze;

/**
  * Skips to the next period state if running, or repeats the state if the controller is waiting. 
 */
-(void)skipToNext;

/** 
  * Suspends the timer period countdown 
 */
-(void)pauseTimer;

/**
  * Resumes the timer period countdown, if any time is left. 
 */
-(void)resumeTimer;

/**
 * Returns a formatted string of the amount of time left til the next stand/sit event.
 */
-(NSString*)stringFromTimeLeft;
@end
