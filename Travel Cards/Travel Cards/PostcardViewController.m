//
//  PostcardViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/25/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "PostcardViewController.h"
#import "CollectionsViewController.h"

@interface PostcardViewController ()

@end

@implementation PostcardViewController
@synthesize locationDatabase,locationName,locationDescription,imageURL,landmarkID,userID,closeEnoughToCheckIn,isADealAvailable,dealText,imageCopyright,imageYear;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //Load the saved User ID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userID = [defaults objectForKey:@"SavedUserID"];
    
    [self obtainObjectID];
    
    self.title=locationName;
    postcardDetails.text = locationDescription;
    postcardImage.image = [self convertURLtoImage:imageURL];
    
    NSString *copyrightText = [[NSString alloc] initWithFormat:@"Image by %@. Copyright %@.",imageCopyright,imageYear];
    copyright.text = copyrightText;
    
    int deal = [isADealAvailable intValue];
    
    if (deal == 1)
    {
        [postcardTitle setTitle:@"Tap here for a great deal!" forState:UIControlStateNormal];
        postcardTitle.hidden = false;
    }
    
    [self setFonts];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage*)convertURLtoImage:(NSString*)url
{
    id path = (NSString*)url;
    NSURL *thisURL = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:thisURL];
    UIImage *image = [[UIImage alloc] initWithData:data];
    return image;
}

-(void)obtainObjectID
{
    NSString *collectionString = [[NSString alloc] initWithFormat:@"%@Collection",locationDatabase];
    query = [PFQuery queryWithClassName:collectionString];
    [query whereKey:@"userID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                thisObjectID = object.objectId;
                NSString *landmarkOwned = [object objectForKey:landmarkID];
                if (landmarkOwned != nil)
                {
                    [self updateButtonIfOwned:landmarkOwned];
                } else if (!closeEnoughToCheckIn) //Are we close enough to check in? If not, let's stop the user from being able to check-in.
                {
                    [addToCollectionButton setTitle:@"Not Close Enough to Check In!" forState:UIControlStateNormal];
                    [addToCollectionButton setEnabled:false];
                }
            }
            thisView.hidden = FALSE;
        } else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)updateButtonIfOwned:(NSString*)dateOwned
{
    NSString *collectionString = [[NSString alloc] initWithFormat:@"Collected on: %@",dateOwned];
    [addToCollectionButton setTitle:collectionString forState:UIControlStateNormal];
    [addToCollectionButton setEnabled:false];
}

-(IBAction)addCardToCollection:(id)sender
{
    NSDate *thisDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:thisDate];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:thisObjectID block:^(PFObject *collectionObject, NSError *error)
    {
        collectionObject[landmarkID] = stringFromDate;
        NSNumber *thisNumberCollected = [collectionObject objectForKey:@"numberOfCollected"];
        int newNumberInt = [thisNumberCollected intValue] + 1;
        numberCollected = [NSNumber numberWithInt:newNumberInt];
        collectionObject[@"numberOfCollected"] = numberCollected;
        [collectionObject saveInBackground];
    }];
    [self checkForAchievement];
    [addToCollectionButton setTitle:@"Already collected!" forState:UIControlStateNormal];
    [addToCollectionButton setEnabled:false];
    locationNameLabel.text = locationName;
    modalView.hidden = false;
    mainView.layer.opacity = .35f;
}

-(void)checkForAchievement
{
    PFQuery *achievementQuery = [PFQuery queryWithClassName:@"Achievements"];
    [achievementQuery whereKey:@"achievementCategory" equalTo:locationDatabase];
    [achievementQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in objects)
             {
                 NSNumber *checkinsNeeded = [object objectForKey:@"checkinsNeeded"];
                 if ([checkinsNeeded isEqualToNumber:numberCollected])
                 {
                     NSNumber *achievementScore = [object objectForKey:@"numberOfPoints"];
                     NSString *achievementName = [object objectForKey:@"achievementName"];
                     NSString *achievementDescription = [object objectForKey:@"achievementDescription"];
                     NSString *objectID = object.objectId;
                     [self collectAchievement:objectID newScore:achievementScore];
                     UIAlertView *achievementAlert = [[UIAlertView alloc] initWithTitle:achievementName message:achievementDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     achievementAlert.alertViewStyle = UIAlertViewStyleDefault;
                     [achievementAlert show];
                 }
             }
         }
     }];
}

-(void)collectAchievement:(NSString*)objectID newScore:(NSNumber*)scoreToAdd
{
    PFQuery *achievementCollection = [PFQuery queryWithClassName:@"AchievementCompletion"];
    [achievementCollection whereKey:@"userID" equalTo:userID];
    [achievementCollection findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in objects)
             {
                 NSNumber *currentScore = [object objectForKey:@"score"];
                 int newScore = [currentScore intValue] + [scoreToAdd intValue];
                 object[objectID] = @1;
                 object[@"score"] = [NSNumber numberWithInt:newScore];
                 [object saveInBackground];
             }
         }
     }];

}


-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    UIFont *thinFont = [UIFont fontWithName:@"Antipasto-ExtraLight" size:15];
    UIFont *smallFont = [UIFont fontWithName:@"Antipasto-ExtraLight" size:12];
    postcardTitle.titleLabel.font=font;
    [postcardDetails setFont:thinFont];
    addToCollectionButton.titleLabel.font = boldFont;
    [welcomeTo setFont:font];
    [locationNameLabel setFont:font];
    [shareThisWith setFont:font];
    [yourFriends setFont:font];
    facebookButton.titleLabel.font = boldFont;
    twitterButton.titleLabel.font = boldFont;
    closeButton.titleLabel.font = boldFont;
    [copyright setFont:smallFont];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
}

-(IBAction)closeModalView:(id)sender
{
    modalView.hidden = TRUE;
    mainView.layer.opacity = 1.0f;
}

-(IBAction)clickFacebookButton:(id)sender
{
    SLComposeViewController *postToFacebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if (postToFacebook != nil)
    {
        NSString *post= [NSString stringWithFormat:@"I just checked into %@ using the Travel Cards App! Check it out at (PLACEHOLDER URL).",locationName];
        [postToFacebook setInitialText:post];
        [self presentViewController:postToFacebook animated:true completion:nil];
    }
}

-(IBAction)clickTwitterButton:(id)sender
{
    SLComposeViewController *postTweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if (postTweet != nil)
    {
        NSString *tweet= [NSString stringWithFormat:@"I just checked into %@ using the Travel Cards App! Check it out at (PLACEHOLDER URL).",locationName];
        [postTweet setInitialText:tweet];
        [self presentViewController:postTweet animated:true completion:nil];
    }
}

-(IBAction)clickDealButton:(id)sender
{
    UIAlertView *dealAlert = [[UIAlertView alloc] initWithTitle:@"Special deal!" message:dealText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    dealAlert.alertViewStyle = UIAlertViewStyleDefault;
    [dealAlert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


@end
