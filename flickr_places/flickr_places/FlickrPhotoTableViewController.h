//
//  FlickrPhotoTableViewController.h
//  flickr_places
//
//  Created by Scott Kensell on 1/30/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableViewController.h"

@interface FlickrPhotoTableViewController : CommonTableViewController

// Lists < 50 photos from the following place
@property (nonatomic, strong) NSString *placeID;

@end
