//
//  SDAAppController.m
//  Standing Desk App
//
//  Created by David Vera on 12/28/13.
//  Copyright (c) 2013 Puppy Bongos. All rights reserved.
//

#import "SDAAppController.h"
#import "SDAIdleDetector.h"

#define SDA_TIMER_INTERVAL      1.0

@implementation SDAAppController

@synthesize settings;
@synthesize delegate;
@synthesize currentActionState = _actionState;
@synthesize currentStatus = _currentStatus;
@synthesize currentTimeLeft = _currentTimeLeft;

-(id)init {
    self = [super init];
    if(self) {
        
        // Start with empty settings
        self.settings = [SDAAppSettings defaultSettings];
        
        _actionState = SDAActionStateNone;
        _currentTimeLeft = 0;
        _lastUpdateTime = 0;
        
        self.delegate = nil;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:SDA_TIMER_INTERVAL target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
        // Add the timer to the main loop to avoid situations where the timer updates cease due to threading issues with UI components.
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}


#pragma mark - Public interface
-(void)loadSettings {
    self.settings = [SDAAppSettings settingsFromFile:[self getConfigPath]];
}

-(void)saveSettings {
    
    NSString* error = nil;
    
    NSDictionary* pList = [self.settings toDictionary];
    
    // Save our settings into our configuration plist
    NSData* data = [NSPropertyListSerialization dataFromPropertyList:pList format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    NSString *configPath = [self getConfigPath];
    if(data) {
        [data writeToFile:configPath atomically:YES];
    }
    
    if(error) {
        NSLog(@"SDAAppController: Settings failed to save. %@", error);
    }
}

-(void)scheduleSit {
    _actionState = SDAActionStateSitting;
    _currentTimeLeft = settings.sittingInterval;
    _lastUpdateTime = [self now];
    
    _currentStatus = SDAStatusRunning;
    NSLog(@"Setting state to: SITTING for %d seconds", settings.sittingInterval);
}

-(void)scheduleStand {
    _actionState = SDAActionStateStanding;
    _currentTimeLeft = settings.standingInterval;
    _lastUpdateTime = [self now];
    
    _currentStatus = SDAStatusRunning;
    NSLog(@"Setting state to: STANDING for %d seconds", settings.standingInterval);
}

-(void)snooze {
    _currentTimeLeft += settings.snoozeTime;
    _currentStatus = SDAStatusRunning;
    
    NSLog(@"Snoozing: Adding %d seconds", settings.snoozeTime);
}

-(void)skipToNext {
    
    NSLog(@"SKIPPING ...");
    if(_currentStatus == SDAStatusWaiting) {
        // Period has ended, app is waiting for user response
        // User has pressed 'sKip'
        
        // Assume user wants to skip the next event, so in essence,
        // repeat the current event
        if(_actionState == SDAActionStateSitting) {
            [self scheduleSit];
        } else {
            [self scheduleStand];
        }
    }
    else if(_currentStatus == SDAStatusRunning) {
        // Assume user wants to skip to the next event if
        // timer is already running
        // So, switch to opposite action state
        if(_actionState == SDAActionStateSitting) {
            [self scheduleStand];
        } else {
            [self scheduleSit];
        }
    }
}

-(void)pauseTimer {
    if(_currentStatus == SDAStatusRunning)
        _currentStatus = SDAStatusPaused;
    
    NSLog(@"Pausing Timer");
}

-(void)resumeTimer {
    if((_currentStatus == SDAStatusPaused) && _currentTimeLeft > 0)
        _currentStatus = SDAStatusRunning;
    
    NSLog(@"Resuming Timer");
}

-(NSString*)stringFromTimeLeft {
    NSUInteger seconds = (NSUInteger)round(_currentTimeLeft);
    NSString *string = [NSString stringWithFormat:@"%02lu:%02lu:%02lu",
                        (seconds / 3600), (seconds / 60) % 60, (seconds % 60)];
    return string;
}

#pragma mark - Internal methods
-(void)checkForIdleState {
    
    //check idle system time
    NSTimeInterval idleTime = [SDAIdleDetector secondsSinceIdle];
    
    bool isIdle = idleTime >= settings.idlePauseTime;
    if(!isIdle && _currentStatus == SDAStatusIdle) {
        // Resume timer.
        
        _currentStatus = SDAStatusRunning;
    }
    else if(isIdle && _currentStatus == SDAStatusRunning) {
        
        // Place it in a idle-paused state
        _currentStatus = SDAStatusIdle;
    }
}


// Fires every second
-(void)updateTime {
    
    [self checkForIdleState];
    
    if(_currentStatus != SDAStatusRunning) {
        
        // if we're not running, make sure time is still
        // moving
        _lastUpdateTime = [self now];
        return;
    }
    
    
    
    // Find out how much time has occurred since last fire
    NSTimeInterval now = [self now];
    NSTimeInterval timeDelta = now - _lastUpdateTime;
    
    // Decrement time if there is time to be taken
    if(_currentTimeLeft > 0) {
        _currentTimeLeft -= timeDelta;
    }
    
    // Forward each tick upwards
    [self fireTickOccurred];
    
    // Check if we've crossed the time threshold and
    // we're not already running
    if(_currentTimeLeft <= 0) {
        _currentStatus = SDAStatusWaiting;
        
        // Only fire event once.
        [self fireStatusIntervalElapsed];
    }
    
    _lastUpdateTime = now;
    
    //NSLog(@"%@", [self stringFromTimeLeft]);
}

#pragma mark - Event Triggers
-(void)fireTickOccurred {
    if([self.delegate conformsToProtocol:@protocol(SDAApplicationDelegate)]) {
        
        // Fire the event to any listeners
        [self.delegate runningTickDidOccur:self];
    }
}


-(void)firePauseForIdleEvent {
    if([self.delegate conformsToProtocol:@protocol(SDAApplicationDelegate)]) {
        
        // Fire the event to any listeners
        [self.delegate appDidPauseForIdle:self];
    }
}

-(void)fireResumeFromIdleEvent {
    if([self.delegate conformsToProtocol:@protocol(SDAApplicationDelegate)]) {
        
        // Fire the event to any listeners
        [self.delegate appDidResumeFromIdle:self];
    }
}

-(void)fireStatusIntervalElapsed {
    
    NSLog(@"Firing event: actionPeriodDidComplete");
    // Ensure that whoever subscribes to this also conforms to it
    if([self.delegate conformsToProtocol:@protocol(SDAApplicationDelegate)]) {

        // Fire the event to any listeners
        [self.delegate actionPeriodDidComplete:self actionState:_actionState];
    }
}

#pragma mark - Utility methods
/** Shortcut for NSDate's retrieval of current time */
-(NSTimeInterval) now {
   return [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceReferenceDate];
}

/** Retrieves the file path of the SDA App's configuration file */
-(NSString*) getConfigPath {
    NSString* appPath = [NSSearchPathForDirectoriesInDomains
                         (NSDocumentDirectory, NSUserDomainMask, YES)
                         objectAtIndex:0];
    
    // Get a full path to the application configuration file
    NSString* configPath = [appPath stringByAppendingPathComponent:@"sda_config.plist"];
    
    // Check if this exists locally. If not, try the bundle path
    if(![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        configPath = [[NSBundle mainBundle] pathForResource:@"sda_config"
                                                     ofType:@"plist"];
    }
    
    return configPath;
}
@end
