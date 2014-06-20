//
//  MainMenuViewController.m
//  Travel Cards
//
//  Created by Scott Caruso on 6/20/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

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
    [self.navigationItem setHidesBackButton:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//This creates the rows for the ViewController table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

//This feeds the data for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    NSString *menuItem;
    
    UITableViewCell *thisCell;
    if (indexPath.row == 0)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Collections"];
        menuItem = @"Collections";
    } else if (indexPath.row == 1)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Achievements"];
        menuItem = @"Achicevements";
    } else if (indexPath.row == 2)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"Settings"];
        menuItem = @"Settings";
    } else if (indexPath.row == 3)
    {
        thisCell = [tableView dequeueReusableCellWithIdentifier:@"User"];
        menuItem = @"User Control";
    }
    if (thisCell == nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    thisCell.textLabel.text = menuItem;
    thisCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return thisCell;
}



@end
