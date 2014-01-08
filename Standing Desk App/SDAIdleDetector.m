//
//  SDAIdleDetector.m
//  Standing Desk App
//
//  Created by David Vera on 1/8/14.
//  Copyright (c) 2014 Puppy Bongos. All rights reserved.
//

#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CFNumber.h>

#import "SDAIdleDetector.h"

@implementation SDAIdleDetector

+(NSTimeInterval)secondsSinceIdle {
    return (NSTimeInterval)SystemIdleTime();
}

/**
 Returns the number of seconds the machine has been idle or -1 if an error occurs.
 The code is compatible with Tiger/10.4 and later (but not iOS).
 
 * Snippet taken from http://programmer.aleksandarsabo.com/code-snippets/detect-user-idle-time-on-mac-os-x
 */
int64_t SystemIdleTime(void) {
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry)  {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = (CFNumberRef) CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds / 1000000000); // Convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    return idlesecs;
}

@end

