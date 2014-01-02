//
//  SystemSounds.m
//  SystemSounds
//
//  Created by Michael Chadwick on 1/1/14.
//  Copyright (c) 2014 TestCo. All rights reserved.
//

#import "SystemSounds.h"

@implementation NSSound (systemSounds)

static NSArray *systemSounds = nil;

+ (NSArray *) systemSounds
{
  if ( !systemSounds )
  {
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    NSEnumerator *librarySources = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES) objectEnumerator];
    NSString *sourcePath;

    while ( sourcePath = [librarySources nextObject] )
    {
      NSEnumerator *soundSource = [[NSFileManager defaultManager] enumeratorAtPath: [sourcePath stringByAppendingPathComponent: @"Sounds"]];
      NSString *soundFile;
      while ( soundFile = [soundSource nextObject] )
        if ( [NSSound soundNamed: [soundFile stringByDeletingPathExtension]] )
          [returnArr addObject: [soundFile stringByDeletingPathExtension]];
    }

    systemSounds = [[NSArray alloc] initWithArray: [returnArr sortedArrayUsingSelector:@selector(compare:)]];
  }
  return systemSounds;
}

@end