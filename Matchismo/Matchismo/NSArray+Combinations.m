//
//  NSArray+Combinations.m
//  Matchismo
//
//  Created by Scott Kensell on 1/5/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "NSArray+Combinations.h"

#define MAX_COMBINATIONS_ALLOWED 10000

@implementation NSArray (Combinations)

- (NSArray *)allCombinationsOfSize:(NSUInteger)size {
    // recursively collect all the combinations
    
    if ([self numberOfCombinationsOfSize:size] > MAX_COMBINATIONS_ALLOWED) return nil;
    else if (size > [self count]) return nil;
    else if (size == 0) return @[];
    else if (size == 1) {
        NSMutableArray *singletons = [[NSMutableArray alloc] init];
        for (id obj in self) {
            [singletons addObject:@[obj]];
        }
        return singletons;
    } else {
        NSMutableArray *combinations = [[NSMutableArray alloc] init];
        for (int i = [self count] - 1; i >= size - 1; i--) {
            
            id largest = [self objectAtIndex:i];
            NSArray *others = [self subarrayWithRange:NSMakeRange(0, i)];
            
            for (NSArray *c in [others allCombinationsOfSize:(size - 1)]) {
                [combinations addObject:[c arrayByAddingObject:largest]];
            };

        }
        return combinations;
    }
}

- (NSUInteger)numberOfCombinationsOfSize:(NSUInteger)size {
    // calculates N choose size
    NSUInteger n = [self count];
    float result = 1;
    for (int i=0; i < size; i++) {
        result *= ((float)(n-i))/(size - i);
    }
    return (int)result;
}

@end
