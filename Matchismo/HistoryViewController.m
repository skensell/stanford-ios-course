//
//  HistoryViewController.m
//  Matchismo
//
//  Created by Scott Kensell on 11/28/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *HistoryTextView;

@end

@implementation HistoryViewController

- (void)viewWillAppear:(BOOL)animated {
    [self updateUI];
}

- (void)updateUI {
    NSLog(@"updating UI of History View");
    NSMutableAttributedString *history = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *separator = [[NSAttributedString alloc] initWithString:@"\n--------\n"];
    for (NSAttributedString *status in [self.history reverseObjectEnumerator]) {
        [history appendAttributedString:status];
        [history appendAttributedString:separator];
    }
    
    self.HistoryTextView.attributedText = history;
    self.HistoryTextView.textAlignment = NSTextAlignmentCenter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


@end
