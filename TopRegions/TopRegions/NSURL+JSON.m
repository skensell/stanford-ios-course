//
//  NSURL+JSON.m
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "NSURL+JSON.h"
#import "Common.h"

@implementation NSURL (JSON)

- (NSDictionary *)dictFromJSONData {
    NSDictionary *aDict = nil;
    NSData *JSONData = [NSData dataWithContentsOfURL:self];
    if (JSONData) {
        NSError *error;
        aDict = [NSJSONSerialization JSONObjectWithData:JSONData
                                                options:0
                                                  error:&error];
        if (error) {
            ERROR(@"Problems occurred during deserializing : %@", [error localizedDescription]);
        }
    }
    return aDict;
}

@end
