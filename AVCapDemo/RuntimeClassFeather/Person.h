//
//  Personal.h
//  AVCapDemo
//
//  Created by 刘隆昌 on 2020/4/5.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
{
    //添加两个成员变量
    NSString* _occupation;//职业
    NSString* _nationality;//国籍
}


@property(nonatomic,copy)NSString* name;
@property(nonatomic,assign)NSInteger age;

//属性方法
-(NSDictionary*)allProperties;
-(NSDictionary*)allIvars;
-(NSDictionary*)allMethods;



@end

NS_ASSUME_NONNULL_END
