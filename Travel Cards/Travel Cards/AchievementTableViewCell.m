//
//  AchievementTableViewCell.m
//  Travel Cards
//
//  Created by Scott Caruso on 7/9/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "AchievementTableViewCell.h"

@implementation AchievementTableViewCell
@synthesize ranking,userName,score;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
