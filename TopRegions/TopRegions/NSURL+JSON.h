//
//  NSURL+JSON.h
//  TopRegions
//
//  Created by Scott Kensell on 2/16/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (JSON)

- (NSDictionary *)dictFromJSONData;
@end
