//
//  LocationViewController.h
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTableCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOutlet;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapViewOutlet;

@end
