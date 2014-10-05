//
//  LocationViewController.m
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () {
    NSMutableArray *locations;
    NSDictionary *locationOne;
    NSDictionary *locationTwo;
    NSDictionary *locationThree;
    NSDictionary *locationFour;
    NSArray *searchResults;
    NSMutableArray *loc;
}

@end

@implementation LocationViewController

@synthesize locationTableView = _locationTableView;
@synthesize searchBarOutlet = _searchBarOutlet;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //map
    self.mapViewOutlet.delegate = self;
    [self.mapViewOutlet setShowsUserLocation:YES];
    
    //user location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    //[locationManager startUpdatingLocation];
    
    _locationTableView.dataSource = self;
    _locationTableView.delegate = self;
    loc = [NSArray arrayWithObject:@"Location"];
    locations = [[NSMutableArray alloc] init];
    locationOne = [[NSMutableDictionary alloc] init];
    locationTwo = [[NSMutableDictionary alloc] init];
    locationThree = [[NSMutableDictionary alloc] init];
    locationFour = [[NSMutableDictionary alloc] init];
    locationOne = @{
                    @"Location" : @"RSF",
                    @"Coordinates" : [NSArray arrayWithObjects:[NSNumber numberWithInt:19], [NSNumber numberWithInt:19], nil],
                    @"numPeople" : [NSNumber numberWithInt:123],
                    };
    locationTwo = @{
                    @"Location" : @"Moffit",
                    @"Coordinates" : [NSArray arrayWithObjects:[NSNumber numberWithInt:19], [NSNumber numberWithInt:19], nil],
                    @"numPeople" : [NSNumber numberWithInt:457],
                    };
    locationThree = @{
                    @"Location" : @"Soda Hall",
                    @"Coordinates" : [NSArray arrayWithObjects:[NSNumber numberWithInt:19], [NSNumber numberWithInt:19], nil],
                    @"numPeople" : [NSNumber numberWithInt:340],
                    };
    locationFour = @{
                      @"Location" : @"Memorial Stadium",
                      @"Coordinates" : [NSArray arrayWithObjects:[NSNumber numberWithInt:1000], [NSNumber numberWithInt:500], nil],
                      @"numPeople" : [NSNumber numberWithInt:2500],
                      };
    [locations addObject:locationOne];
    [locations addObject:locationTwo];
    [locations addObject:locationThree];
    [locations addObject:locationFour];
    NSLog(@"%lu", (unsigned long)[locations count]);
}

#pragma mark - MKMapViewDelegate methods.
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
        [mv setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [locations count];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [locations count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LocationTableCell";
    
    LocationTableCell *cell = (LocationTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *temp = [locations objectAtIndex:indexPath.row];
    NSLog(@"We currently have %ld models available", [temp count]);
    for (id key in temp) {
        NSLog(@"There are %@ %@'s in stock", temp[key], key);
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.locationLabel.text = [searchResults objectAtIndex:indexPath.row];
    } else {
        cell.locationLabel.text = @"Location"; //[temp objectForKey:@"Location"];
        cell.numPeopleLabel.text = @"numPeople"; //[temp objectForKey:@"numPeople"];
    }
//    cell.locationLabel.text = @"Location"; //[temp objectForKey:@"Location"];
//    cell.numPeopleLabel.text = @"numPeople"; //[temp objectForKey:@"numPeople"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [loc filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
