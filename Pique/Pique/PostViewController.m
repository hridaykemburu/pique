//
//  PostViewController.m
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController () {
    NSString *newAddress;
}

@end

@implementation PostViewController

CLPlacemark *thePlacemark;
MKRoute *route;

@synthesize postTableView = _postTableView;
@synthesize numPeopleLabel = _numPeopleLabel;
@synthesize numPeople = _numPeople;
@synthesize lat = _lat;
@synthesize longitude = _longitude;
@synthesize posts = _posts;
@synthesize commentTextField = _commentTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(_numPeople);
    _numPeopleLabel.text = [_numPeople copy];
    
    //map
    self.postMap.delegate = self;
    [self.postMap setShowsUserLocation:YES];
    
    //user location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    //[locationManager startUpdatingLocation];
    
    //tableview
    _postTableView.dataSource = self;
    _postTableView.delegate = self;
    
    //keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_commentTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)startTrip:(id)sender {
//    if (_addressTextField.text.length == 0) {
//        if (_addressTextField.text.length == 0) {
//            [[[UIAlertView alloc] initWithTitle:@"Search Failed"
//                                        message:@"Please enter an address."
//                                       delegate:nil
//                              cancelButtonTitle:@"Ok"
//                              otherButtonTitles:nil] show];
//        }
//    }
    //CLLocationCoordinate2D _srcCoord = CLLocationCoordinate2DMake(-6.89400,107.60473);
    //MKPlacemark *_srcMark = [[MKPlacemark alloc] initWithCoordinate:_srcCoord addressDictionary:nil];
    MKMapItem *_srcItem = [MKMapItem mapItemForCurrentLocation];
    //MKMapItem *_srcItem = [[MKMapItem alloc] initWithPlacemark:_srcMark];
    
    //[self textFieldShouldReturn:_addressTextField];
    //NSString *_coordinateStr = [NSString stringWithFormat:@"%f,%f", _lat, _longitude];
    //[self.postMap removeOverlay:route.polyline];
    //newAddress = _coordinateStr;
    //NSLog(@"%@", _coordinateStr);
    //NSArray *_coordParts2 = [newAddress componentsSeparatedByString:@","];
    //NSLog(@"%.8f", _lat);
    //NSLog(@"%.8f", _longitude);
    CLLocationCoordinate2D _destCoord = CLLocationCoordinate2DMake(_lat, _longitude);
    
    //CLLocationCoordinate2D _destCoord = CLLocationCoordinate2DMake(37.8273868, -122.286808);
    MKPlacemark *_destMark = [[MKPlacemark alloc] initWithCoordinate:_destCoord addressDictionary:nil];
    MKMapItem *_destItem = [[MKMapItem alloc] initWithPlacemark:_destMark];
    [self findDirectionsFrom:_srcItem to:_destItem];
}

- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.destination = destination;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    __block typeof(self) weakSelf = self;
    NSLog(@"11111");
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error is %@",error);
         } else {
             NSLog(@"2222");
             route = [response.routes firstObject];
             [self.postMap addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
         }
     }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    NSLog(@"GOT here");
    MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRender.lineWidth = 3.0f;
    polylineRender.strokeColor = [UIColor blueColor];
    return polylineRender;
}

//- (void)geoCodeFromTextField:(UITextField*)textField {
//    NSLog(@"%@", @"geoCodeFromTextField");
////    NSDictionary *address = @{
////                              (NSString *)kABPersonAddressStreetKey: textField.text,
////                              (NSString *)kABPersonAddressCityKey: @"Bandung",
////                              (NSString *)kABPersonAddressCountryCodeKey: @"ID"
////                              };
////    
////    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
////    [geoCoder geocodeAddressDictionary:address completionHandler:^(NSArray *placemarks, NSError *error) {
////        if (error) {
////            NSLog(@"%@", error);
////            [[[UIAlertView alloc] initWithTitle:@"Search Failed"
////                                        message:@"Please enter a valid address."
////                                       delegate:nil
////                              cancelButtonTitle:@"Ok"
////                              otherButtonTitles:nil] show];
////        }
////        else {
////            MKPlacemark *_placemark = [placemarks lastObject];
//    NSString *_coordinateStr = [NSString stringWithFormat:@"%f,%f", _placemark.location.coordinate.latitude, _placemark.location.coordinate.longitude];
//    [self.postMap removeOverlay:route.polyline];
//    newAddress = _coordinateStr;
//    NSLog(@"%@", _coordinateStr);
////        }
////    }];
//}


//#pragma mark - TextField delegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self geoCodeFromTextField:textField];
//    return YES;
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PostTableCell";
    
    PostTableCell *cell = (PostTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *currentPlace = [_posts objectAtIndex:indexPath.row];
    int upVotes = [currentPlace objectForKey:@"upvotes"];
    int downVotes = [currentPlace objectForKey:@"downvotes"];
    int likes = upVotes - downVotes;
    cell.postTextView.text = [currentPlace objectForKey:@"content"];
    cell.numLikes.text =  [NSString stringWithFormat:@"%d", likes];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HELLO");
    //selectedPost = [posts objectAtIndex:indexPath.row];
    //currentTitle = @"Test Title";
    //numPeople = @"100";
    //[self performSegueWithIdentifier:@"toPost" sender:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    //    self.postToolbar.frame = CGRectMake(0, 274, 320, 44);
    //    NSLog(@"%f", self.postToolbar.frame.origin.y);
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.postToolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - keyboardBounds.size.height - self.postToolBar.frame.size.height, self.postToolBar.frame.size.width, self.postToolBar.frame.size.height)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //    self.postToolbar.frame = CGRectMake(0, self.view.bounds.size.height - 44, 320, 44);
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //    CGRect keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.postToolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - 46.0f, self.postToolBar.frame.size.width, self.postToolBar.frame.size.height)];
    [UIView commitAnimations];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)postComment:(id)sender {
    if (sender != self.postButton) return;
    if (self.commentTextField.text.length > 0) {
        
    }
    
}
@end
