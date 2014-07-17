//
//  CollectionsViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/23/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
{
    int numberOfLocations;
    NSMutableArray *listOfLandmarks;
    NSMutableArray *listOfURLs;
    NSMutableArray *listOfDescriptions;
    NSMutableArray *listOfLandmarkCodes;
    NSMutableArray *collectionStatus;
    IBOutlet UICollectionView *collectionView;
}

@property NSString *cityCodeName;
@property NSString *cityName;
@property NSNumber *userID;

-(void)retrieveNumberOfLandmarks;
-(UIImage*)convertURLtoImage:(NSString*)url;

@end
