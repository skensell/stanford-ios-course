//
//  CommonTableViewController.h
//  flickr_places
//
//  Created by Scott Kensell on 2/3/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrFetcher.h"
#import "Common.h"

@interface CommonTableViewController : UITableViewController

// PROTECTED
@property (nonatomic, strong, readonly) NSArray *fetchedDataFromFlickr; // populated by the method below
- (IBAction)fetchFlickrDataAtURL:(NSURL *)url keyPath:(NSString *)keyPath;

- (void)prepareFetchedDataForTableReload; // a chance to refine fetchedData before loading table

@end
