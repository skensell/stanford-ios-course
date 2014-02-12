//
//  HistoryViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/29/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "HistoryTableViewController.h"

@interface HistoryTableViewController ()
@property (nonatomic, strong, readwrite) NSArray *fetchedDataFromFlickr;
@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"History";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *history = [[NSUserDefaults standardUserDefaults] objectForKey:kHistoryKey];
    self.fetchedDataFromFlickr = history;
}

- (void)fetchFlickrData {
    // need this here so that we don't make the asynch call which the parent class makes
}
@end
