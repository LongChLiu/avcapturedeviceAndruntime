//
//  AppDelegate.m
//  AVCapDemo
//
//  Created by 刘隆昌 on 2020/4/4.
//  Copyright © 2020 刘隆昌. All rights reserved.
//

#import "AppDelegate.h"
#import "Person.h"
#import <objc/runtime.h>
#import <objc/message.h>


@interface AppDelegate ()

@end


void sayFunction(id self,IMP _cmd,id some){
    NSLog(@"%@岁的%@说:%@",object_getIvar(self, class_getInstanceVariable([self class], "_age")),[self valueForKey:@"name"],some);
}



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    
//    通过 runtime 获取对象的特性,比如属性,实例变量和方法等,
//    其中主要使用到的runtime 函数是.
//    1).class_copyPropertyList—获取一个类的所有属性，如果没有属性count就为0
//    2).property_getName—获取属性名称
//    3).objc_property_t—接收class_copyPropertyList返回的属性地址指针
//    4).free—使用free函数来释放objc_property_t指针数组内存
//    5).class_copyIvarList—通过传入一个类,获取这个类所有的实例变量
//    6).ivar_getName—通过传入数组中的一个实例变量元素返回一个实例变量的字符
//    7).class_copyMethodList—通过传入一个类,获取这个类所有的方法
//    8).method_getName—-通过传入数组中的一个实例变量元素返回一个方法名称,为一个 SEL方法选择器
//    9).sel_getName—通过传入的 SEL方法名称,返回方法字符
//    10).method_getNumberOfArguments—返回由方法接受的参数个数。    
    
    Person* teacherChange = [[Person alloc] init];
    teacherChange.name = @"苍井空";
    teacherChange.age = 18;
    [teacherChange setValue:@"老师" forKey:@"occupation"];
    
    NSDictionary* propertyResultDict = [teacherChange allProperties];
    for (NSString* propertyResultStr in propertyResultDict.allKeys) {
        NSLog(@"propertyName: %@, propertyValue:  %@",propertyResultStr, propertyResultDict[propertyResultStr]);
    }
    
    
    NSDictionary* ivarResultDic = [teacherChange allIvars];
    for (NSString* ivarName in ivarResultDic.allKeys) {
        NSLog(@"ivarName: %@, ivarValue: %@",ivarName,ivarResultDic[ivarName]);
    }
    
    NSDictionary* methodResultDic = [teacherChange allMethods];
    for (NSString* methodName in methodResultDic.allKeys) {
        NSLog(@"methodName: %@, argumentsCount: %@",methodName,methodResultDic[methodName]);
    }
    
    
    
    
    /*
     动态添加类及类属性，并为类动态添加方法
     */
    /*获取类的属性、实例变量、方法*/
    //    在动态添加类及属性这块,主要用的的 runtime函数是
    //    1).objc_allocateClassPair—–通过这个函数,可以创建出一个类
    //    2).class_addIvar—–为该类添加实例变量
    //    3).sel_registerName—–注册一个 SEL方法
    //    4).class_addMethod—–为创建的类动态添加方法
    //    5).objc_registerClassPair—–为创建的类进行注册
    //    6).class_getInstanceVariable—–获取类中的实例变量
    //    7).object_setIvar—–为对象中的变量赋值
    //    8).objc_disposeClassPair—–销毁创建出来的类
    
    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    //为创建的这个类添加实例变量，在这里添加一个name的字符串实例变量、一个int型的age实例变量
    /*
     第一个参数: 为哪一个类添加实例变量
     第二个参数: 实例变量的名称
     第三个参数：申请内存地址大小
     第四个参数：实例变量类型
     */
    class_addIvar(People, "_name", sizeof(NSString*), log2(sizeof(NSString*)), @encode(NSString*));
    
    class_addIvar(People, "_age", sizeof(int), sizeof(int), @encode(int));
    
    //注册方法名
    SEL s = sel_registerName("say:");
    
    /*
     第一个参数： 为哪个类添加方法
     第二个参数：指定添加的SEL方法名
     第三个参数：IMP是“implementation”的缩写，它是由编译器生成的一个函数指针，当你发起一个消息后，这个函数指针决定了最终执行哪段代码。
     第四个参数：确定方法的参数以及返回值
     */
    class_addMethod(People, s, (IMP)sayFunction, "v@:@");
    
    //注册该类
    objc_registerClassPair(People);
    
    //通过该类创建一个实体的对象
    id peopleInstance = [[People alloc] init];
    //给对象的name实例变量赋值
    [peopleInstance setValue:@"苍老师" forKey:@"name"];
    
    //获取类中的另外一个实例变量
    //第一个参数 获取哪个类的实例变量
    //第二个参数 获取实例变量的名字
    Ivar ageIvar = class_getInstanceVariable(People, "_age");
    
    /*
     给对象中的实例变量赋值
     第一个参数：赋值对象
     第二个参数：需要赋值的对象实例变量
     第三个参数：该实例变量的值
     */
    object_setIvar(peopleInstance, ageIvar, @18);
    
    //调用peopleInstance对象中的s方法选择器对应的方法
    /*
     第一个参数：通过哪个对象调用方法
     第二个参数：调用的哪个方法，在前面注册了一个s方法选择器
     第三个参数：前面添加方法的时候，指定带有一个字符串的参数
     */
    ((void(*)(id,SEL,id))objc_msgSend)(peopleInstance,s,@"大家好");
    //调用完成，将对象置为空
    peopleInstance = nil;
    
    //通过objc销毁类 销毁的是一个类 不是对象
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
