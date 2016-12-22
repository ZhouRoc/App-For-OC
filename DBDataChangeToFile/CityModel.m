//
//  CityModel.m
//  DBDataChangeToFile
//
//  Created by roc on 16/12/15.
//  Copyright © 2016年 roc. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_alias forKey:@"alias"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_num] forKey:@"num"];
    [aCoder encodeObject:UIImagePNGRepresentation(_icon) forKey:@"icon"];
    
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.alias = [aDecoder decodeObjectForKey:@"alias"];
    self.num = [[aDecoder decodeObjectForKey:@"num"] integerValue];
    self.icon = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"icon"]];
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@-%@",_name,_alias];
}

@end
