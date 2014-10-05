//
//  PostTableCell.h
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;

@end
