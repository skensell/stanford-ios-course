//
//  TextStatsViewController.m
//  Attributor
//
//  Created by Scott Kensell on 11/20/13.
//  Copyright (c) 2013 Scott Kensell. All rights reserved.
//

#import "TextStatsViewController.h"

@interface TextStatsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *colorfulCharactersLabel;
@property (weak, nonatomic) IBOutlet UILabel *outlinedCharactersLabel;

@end

@implementation TextStatsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
//    //uncomment to test
//    self.textToAnalyze = [[NSAttributedString alloc] initWithString:@"text"
//                                                         attributes:@{ NSForegroundColorAttributeName :[UIColor greenColor],
//                                                                       NSStrokeWidthAttributeName : @-3}];
}

-(void)setTextToAnalyze:(NSAttributedString *)textToAnalyze {
    
    _textToAnalyze = textToAnalyze;
    if (self.view.window) [self updateUI];
}


- (void)updateUI {
    self.colorfulCharactersLabel.text = [NSString stringWithFormat:@"%d colorful characters", [[self charactersWithAttribute:NSForegroundColorAttributeName] length]];
    self.outlinedCharactersLabel.text = [NSString stringWithFormat:@"%d outlined characters", [[self charactersWithAttribute:NSStrokeWidthAttributeName] length]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUI];
}

- (NSAttributedString *)charactersWithAttribute:(NSString *)attributeName {
    
    NSMutableAttributedString *characters = [[NSMutableAttributedString alloc] init];
    
    int index = 0;
    while (index < [self.textToAnalyze length]){
        NSRange range; // range is a struct
        id value = [self.textToAnalyze attribute:attributeName atIndex:index effectiveRange:&range];
        if (value){
            [characters appendAttributedString:[self.textToAnalyze attributedSubstringFromRange:range]];
            index = range.location + range.length;
        } else {
            index++;
        }
    }
    
    return characters;
}


@end
