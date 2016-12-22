//
//  CityModel.h
//  DBDataChangeToFile
//
//  Created by roc on 16/12/15.
//  Copyright © 2016年 roc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CityModel : NSObject <NSCoding>

@property (strong,nonatomic) NSString *name,*alias;
@property (strong,nonatomic) UIImage  *icon;
@property (assign,nonatomic) NSInteger num;

@end
