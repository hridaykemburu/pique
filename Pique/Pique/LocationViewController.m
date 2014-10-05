//
//  LocationViewController.m
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () {
    NSArray *searchResults;
    NSString *currentTitle;
    NSString *numPeople;
    NSString *longitude;
    NSString *lat;
    NSArray *jsonArray;
    NSArray *comments;
    float longT;
    float laT;
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
    [locationManager startUpdatingLocation];
    //[locationManager stopUpdatingLocation];
    
    //populate table data
    _locationTableView.dataSource = self;
    _locationTableView.delegate = self;
    
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
        //float long = currentLocation.coordinate.longitude;
        longT = currentLocation.coordinate.longitude;
        laT = currentLocation.coordinate.longitude;
        longitude = [[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] copy];
        lat = [[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude] copy];
        NSLog(longitude);
        NSLog(lat);
        
        //GET request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *urlLoc = @"http://192.168.0.114:9000/api/locations?lat=";
        NSString *urlTwo = @"&lon=";
        NSString *finalURL = [[NSString stringWithFormat:@"%@%@%@%@", urlLoc, lat, urlTwo, longitude] copy];
        NSLog(finalURL);
        [request setURL:[NSURL URLWithString:finalURL]];
        [request setHTTPMethod:@"GET"];
        
        NSURLResponse *requestResponse;
        NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
        
        NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
        
        NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *e = nil;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &e];
        
        if (!jsonArray) {
            NSLog(@"Error parsing JSON: %@", e);
        } else {
//            for(NSDictionary *item in jsonArray) {
//                NSLog(@"Item: %@", item);
//            }
        }
        
        //POST request
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"uniqueID"]) {
            NSLog(@"uniqueID already created");
            NSLog([defaults objectForKey:@"uniqueID"]);
            NSDictionary *h = [defaults objectForKey:@"uniqueID"];
            NSLog(h);
            //NSLog([h objectForKey:@"history"]);
            NSDictionary *tmp = @{
                                  @"lat":lat,
                                  @"lon":longitude,
                                  };
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
            //[request setHTTPBody:postData];

            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
            NSString *firstURL = @"http://192.168.0.114:9000/api/phones/";
            NSString *secondURL = [defaults objectForKey:@"uniqueID"];
            NSString *thirdURL = @"/location";
            NSString *finalURL = [[NSString stringWithFormat:@"%@%@%@", firstURL, secondURL, thirdURL] copy];
            [postRequest setURL:[NSURL URLWithString:finalURL]];
            [postRequest setHTTPMethod:@"POST"];
            [postRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [postRequest setHTTPBody:postData];
            
            NSURLResponse *postRequestResponse;
            NSData *postRequestHandler = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&postRequestResponse error:nil];
            
            NSString *postRequestReply = [[NSString alloc] initWithBytes:[postRequestHandler bytes] length:[postRequestHandler length] encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", postRequestReply);
            
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //[defaults setObject:postRequestReply forKey:@"uniqueID"];
            //[defaults synchronize];
        } else {
            NSLog(@"uniqueID created");
            NSString *post = [NSString stringWithFormat:nil];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
            
            NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] init];
            [postRequest setURL:[NSURL URLWithString:@"http://192.168.0.114:9000/api/phones"]];
            [postRequest setHTTPMethod:@"POST"];
            [postRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [postRequest setHTTPBody:postData];
            
            NSURLResponse *postRequestResponse;
            NSData *postRequestHandler = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&postRequestResponse error:nil];
            
            NSString *postRequestReply = [[NSString alloc] initWithBytes:[postRequestHandler bytes] length:[postRequestHandler length] encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", postRequestReply);
            
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //NSDictionary *tempID = (NSDictionary) postRequestReply;
            //NSString *myID = [tempID objectForKey:@"_id"];
            //[defaults setObject:myID forKey:@"uniqueID"];
            [defaults synchronize];
        }
    }
    [locationManager stopUpdatingLocation];
    [_locationTableView reloadData];
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
        return 10;//MIN(10, [jsonArray count]);
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
    NSDictionary *currentPlace = [jsonArray objectAtIndex:indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.locationLabel.text = [searchResults objectAtIndex:indexPath.row];
    } else {
        cell.locationLabel.text = [currentPlace objectForKey:@"name"];
        int pop = [[currentPlace objectForKey:@"population"] intValue];
        cell.numPeopleLabel.text = [NSString stringWithFormat:@"%d", pop];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
    NSDictionary *currentPlace = [jsonArray objectAtIndex:indexPath.row];
    currentTitle = [currentPlace objectForKey:@"name"];
    int pop = [[currentPlace objectForKey:@"population"] intValue];
    numPeople = [NSString stringWithFormat:@"%d", pop];
    comments = [currentPlace objectForKey:@"comments"];
    [self performSegueWithIdentifier:@"toPost" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"toPost"]) {
        //sets correct post for the detail post to load
        PostViewController *postVC = [segue destinationViewController];
        //forumVC.post = selectedPost;
        postVC.title = currentTitle;
        postVC.numPeople = [NSString stringWithFormat:@"%@%@", numPeople, @" people here"];
        postVC.longitude = longT;
        postVC.lat = laT;
        postVC.posts = comments;
    }
}


@end
