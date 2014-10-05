//
//  PostViewController.h
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostTableCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface PostViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    //NSString *title;
}

@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (weak, nonatomic) IBOutlet MKMapView *postMap;
//@property (weak, nonatomic) IBOutlet UILabel *numPeopleLabel;
//@property NSString *title;
@property (weak, nonatomic) IBOutlet UIToolbar *postToolBar;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
- (IBAction)postComment:(id)sender;

@end
