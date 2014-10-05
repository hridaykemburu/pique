//
//  Post.m
//  Pique
//
//  Created by Hriday Kemburu on 10/4/14.
//  Copyright (c) 2014 Hriday Kemburu. All rights reserved.
//

#import "Post.h"

@implementation Post

-(instancetype)init {
    self = [super init];
    if(self) {
        self.location = nil;
        self.population = nil;
        self.comments = [[NSMutableArray alloc] init];
    }
    return self;
}

//These are custom initializers, they need to be in this fashion, follow the steps because they have to be in this order
// Step 1 : self = [super init]; this creates the reference to the actual object and allocates it in memory. some classes have inits like initWithCoder, or initWithNibOrBundle
//                               these require you to use those initializers, but for custom initializers as seen below, you just use the basic [super init];
// Step 2 : if(self) { }         this step is where you check to make sure the object is actually initialized. if it is, then you can go ahead and implement it. if it is null,
//                               this will prevent a seg fault
// Step 3: return self           after your setup you return the pointer to yourself as you would in C++ or C with malloc()

-(instancetype)initWithLocation:(NSString *)location population:(NSString *)population {
    self = [super init];
    if(self) {
        self.location = location;
        self.population = population;
        self.comments = [[NSMutableArray alloc] init];
    }
    return self;
    
}

@end
