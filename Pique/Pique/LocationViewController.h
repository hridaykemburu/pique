//
//  LocationViewController.h
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTableCell.h"

@interface LocationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOutlet;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;

@end
