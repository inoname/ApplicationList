//
//  App.h
//  加载网络图片
//
//  Created by kouliang on 15/1/10.
//  Copyright (c) 2015年 kouliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface App : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *download;

+(instancetype)appWithDict:(NSDictionary *)dict;
@end
