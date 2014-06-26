//
//  PostcardViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/25/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostcardViewController : UIViewController
{
    IBOutlet UILabel *postcardTitle;
    IBOutlet UITextView *postcardDetails;
    IBOutlet UIImageView *postcardImage;
}

@property NSString *locationName;
@property NSString *locationDescription;
@property NSString *imageURL;

-(UIImage*)convertURLtoImage:(NSString*)url;

@end
