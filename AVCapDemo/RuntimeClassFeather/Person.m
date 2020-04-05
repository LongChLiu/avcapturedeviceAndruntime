//
//  Personal.m
//  AVCapDemo
//
//  Created by 刘隆昌 on 2020/4/5.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>



@implementation Person


-(NSDictionary*)allProperties{

    unsigned int count = 0;//传入count地址、返回int型的值到该地址
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary* resultDict = [@{} mutableCopy];
    
    
    for (NSUInteger idx=0; idx<count; idx++) {
        const char * propertyName = property_getName(properties[idx]);
        NSString* name = [NSString stringWithUTF8String:propertyName];;
        //KVC里的方法 通过属性获取其值
        id propertyValue = [self valueForKey:name];
        if (propertyValue) {
            resultDict[name] = propertyValue;
        }else{
            resultDict[name] = @"字典的key对应的value不能为nil";
        }
    }
    
    //这里properties是一个数组指针 需要free函数来释放内存。
    free(properties);
    return resultDict;
}


-(NSDictionary*)allIvars{
    unsigned int count = 0;
    
    Ivar *ivar = class_copyIvarList([self class], &count);
    NSMutableDictionary* resultDict = [@{} mutableCopy];
    for (NSUInteger i=0; i<count; i++) {
        const char* ivarName = ivar_getName(ivar[i]);
        NSString* name = [NSString stringWithUTF8String:ivarName];
        id valueName = [self valueForKey:name];
        if (valueName) {
            resultDict[name] = valueName;
        }else{
            resultDict[name] = @"字典的key对应的value不能为nil";
        }
    }
    free(ivar);
    return resultDict;
}


-(NSDictionary*)allMethods{
    unsigned int count = 0;
    NSMutableDictionary* resultDict = [@{} mutableCopy];
    
    Method *method = class_copyMethodList([self class], &count);
    for (NSUInteger i = 0; i<count; i++) {
        SEL methodSEL = method_getName(method[i]);
        const char* methodName = sel_getName(methodSEL);
        NSString* name = [NSString stringWithUTF8String:methodName];
        
        int arguments = method_getNumberOfArguments(method[i]);
        NSLog(@"%d",arguments);
        resultDict[name] = @(arguments - 2);
    }
    free(method);
    return resultDict;
}















@end
