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
@synthesize locationDatabase,locationName,locationDescription,imageURL,landmarkID,userID;

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
    postcardTitle.text = locationName;
    postcardDetails.text = locationDescription;
    postcardImage.image = [self convertURLtoImage:imageURL];
    
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
            // The find succeeded.
            // Do something with the found object
            for (PFObject *object in objects)
            {
                thisObjectID = object.objectId;
                NSNumber *landmarkOwned = [object objectForKey:landmarkID];
                if ([landmarkOwned intValue] == 1)
                {
                    isThisCardAlreadyOwned = true;
                    [self updateButtonIfOwned:isThisCardAlreadyOwned];
                }
            }
            thisView.hidden = FALSE;
        } else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)updateButtonIfOwned:(bool)owned
{
    if (owned)
    {
        [addToCollectionButton setTitle:@"Collected on: (DATE HERE)" forState:UIControlStateNormal];
        [addToCollectionButton setEnabled:false];
    }
}

-(IBAction)addCardToCollection:(id)sender
{
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:thisObjectID block:^(PFObject *collectionObject, NSError *error)
    {
        collectionObject[landmarkID] = @1;
        [collectionObject saveInBackground];
    }];
    [addToCollectionButton setTitle:@"Already collected!" forState:UIControlStateNormal];
    [addToCollectionButton setEnabled:false];
}

-(void)setFonts
{
    UIFont *font = [UIFont fontWithName:@"Antipasto" size:20];
    UIFont *boldFont = [UIFont fontWithName:@"Antipasto-ExtraBold" size:20];
    UIFont *thinFont = [UIFont fontWithName:@"Antipasto-ExtraLight" size:15];
    [postcardTitle setFont:font];
    [postcardDetails setFont:thinFont];
    addToCollectionButton.titleLabel.font = boldFont;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Antipasto-ExtraBold" size:21],
      NSFontAttributeName, nil]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


@end
