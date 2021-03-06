//
//  CollectionListViewController.h
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionListViewController : UIViewController <UITableViewDelegate>
{
    IBOutlet UITableView *collectionTable;
    int numberOfUnownedRows;
    int numberOfOwnedRows;
    NSNumber *userID;
    
    NSMutableArray *listOfUnownedCities;
    NSMutableDictionary *citiesPlusCodes;
    NSMutableArray *ownedCities;
}

-(void)retrieveNumberOfRowsAndCities;

@end
