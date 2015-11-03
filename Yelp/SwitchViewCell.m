//
//  SwitchViewCell.m
//  Yelp
//
//  Created by David Wang on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "SwitchViewCell.h"

@interface SwitchViewCell ()
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@end

@implementation SwitchViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];

}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self.toggleSwitch setOn:on animated:animated];
}

- (IBAction)switchValueChanged:(id)sender {
    [self.delegate switchCell:self didUpdateValue:self.toggleSwitch.on];
}

@end
