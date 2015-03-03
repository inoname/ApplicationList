//
//  App.m
//  加载网络图片
//
//  Created by kouliang on 15/1/10.
//  Copyright (c) 2015年 kouliang. All rights reserved.
//

#import "App.h"

@implementation App
+(instancetype)appWithDict:(NSDictionary *)dict{
    id obj=[[self alloc]init];
    [obj setValuesForKeysWithDictionary:dict];
    return obj;
}
@end
