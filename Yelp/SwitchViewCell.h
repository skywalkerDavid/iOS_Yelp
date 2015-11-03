//
//  SwitchViewCell.h
//  Yelp
//
//  Created by David Wang on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchViewCell;

@protocol SwitchCellDelegate <NSObject>

- (void) switchCell:(SwitchViewCell *)cell didUpdateValue:(BOOL)value;

@end

@interface SwitchViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) id<SwitchCellDelegate> delegate;
@property (nonatomic, assign) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
