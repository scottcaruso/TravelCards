//
//  PostcardViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/25/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface PostcardViewController : UIViewController
{
    IBOutlet UIButton *postcardTitle;
    IBOutlet UITextView *postcardDetails;
    IBOutlet UIImageView *postcardImage;
    IBOutlet UIView *thisView;
    IBOutlet UIButton *addToCollectionButton;
    NSString *thisObjectID;
    PFQuery *query;
    bool isThisCardAlreadyOwned;
    
    IBOutlet UIView *mainView;
    IBOutlet UIView *modalView;
    IBOutlet UILabel *welcomeTo;
    IBOutlet UILabel *locationNameLabel;
    IBOutlet UILabel *shareThisWith;
    IBOutlet UILabel *yourFriends;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *closeButton;
}

@property NSString *locationDatabase;
@property NSString *locationName;
@property NSString *locationDescription;
@property NSString *imageURL;
@property NSString *landmarkID;
@property NSNumber *userID;
@property NSNumber *isADealAvailable;
@property NSString *dealText;
@property bool closeEnoughToCheckIn;

-(void)obtainObjectID;
-(UIImage*)convertURLtoImage:(NSString*)url;
-(IBAction)addCardToCollection:(id)sender;
-(IBAction)closeModalView:(id)sender;
-(IBAction)clickFacebookButton:(id)sender;
-(IBAction)clickTwitterButton:(id)sender;
-(IBAction)clickDealButton:(id)sender;

@end
