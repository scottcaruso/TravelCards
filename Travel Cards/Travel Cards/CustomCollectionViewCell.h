//
//  CustomCollectionViewCell.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/26/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell
{
    
}

@property (nonatomic) IBOutlet UIImageView *backgroundImage; //outlet for the Twitter icon
@property (nonatomic) IBOutlet UILabel *locationName; //outlet for the Twitter name label

@end
