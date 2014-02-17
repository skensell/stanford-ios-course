//
//  Database.h
//  TopRegions
//
//  Created by Scott Kensell on 2/15/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#ifndef TopRegions_Database_h
#define TopRegions_Database_h

#import <UIKit/UIKit.h>

@protocol DatabaseDelegate <NSObject>
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
@end


#endif
