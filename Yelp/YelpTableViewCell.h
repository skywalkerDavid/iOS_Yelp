//
//  YelpTableViewCell.h
//  Yelp
//
//  Created by David Wang on 10/30/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YelpBusiness.h"

@interface YelpTableViewCell : UITableViewCell
@property (nonatomic, strong) YelpBusiness *business;
@end
