//
//  SDAIdleDetector.h
//  Standing Desk App
//
//  Created by David Vera on 1/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDAIdleDetector;

@interface SDAIdleDetector : NSObject {
    int _secondsIdle;
}
+(NSTimeInterval)secondsSinceIdle;
@end
