//
//  Post.h
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *population;
@property (nonatomic, strong) NSMutableArray *comments;

-(instancetype)initWithLocation:(NSString *)location population:(NSString *)population;

@end
