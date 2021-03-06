//
//  Item.h
//  Homepwner
//
//  Created by wayne on 14-4-21.
//  Copyright (c) 2014年 wayne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) double order;
@property (nonatomic, retain) NSString * serial;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic) int value;
@property (nonatomic, retain) NSManagedObject *toAsset;

- (void)setThumbNailFromImage:(UIImage *)image;
@end
