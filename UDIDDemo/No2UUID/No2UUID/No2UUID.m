//
//  No2UUID.m
//  No2UUID
//
//  Created by zhaojun on 16/7/26.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import "No2UUID.h"
#import <UIKit/UIDevice.h>

@interface No2UDIDManager : NSObject{
    NSString* _uid;
    NSString* _uidKey;
}
+ (No2UDIDManager* __nullable)sharedInstance;
- (NSString* __nullable) uuid;
@end

@implementation No2UDIDManager
static No2UDIDManager* _instance = nil;
+ (No2UDIDManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [No2UDIDManager new];
    });
    return _instance;
}

- (id) init
{
    self = [super init];
    _uidKey = @"No2AppUUID";
    _uid = nil;
    return self;
}

/**
 * uuid
 */
- (NSString*) uuid
{
    /*if (!_uid)*/ _uid = [self valueForKeychainKey:_uidKey service:_uidKey];
    /*if (!_uid)*/ _uid = [self valueForUserDefaultsKey:_uidKey];
    /*if (!_uid)*/ _uid = [self ifa];
    /*if (!_uid)*/ _uid = [self ifv];
    /*if (!_uid)*/ _uid = [self randomUUID];
    [self save];
    return _uid;
}

#pragma mark - GetUUID Start
/**
 * ifa 方法获取uuid
 */
- (NSString*) ifa
{
    NSString *ifaId = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) { // a dynamic way of checking if AdSupport.framework is available
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifaId = [advertisingIdentifier UUIDString];
        NSLog(@"ifa uuid : %@", ifaId);
    }
    return ifaId;
}

/**
 * ifv 方式获取uuid
 */
- (NSString*) ifv
{
    NSString *ifvId = nil;
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        ifvId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        NSLog(@"ifv uuid : %@", ifvId);
    }
    return ifvId;
}

/**
 * 随机生成 uuid
 */
- (NSString*) randomUUID
{
    NSString *rUUID = nil;
    if(NSClassFromString(@"NSUUID")) { // only available in iOS >= 6.0
        rUUID = [[NSUUID UUID] UUIDString];
        NSLog(@"NSUUID uuid : %@", rUUID);
    }
    if (rUUID == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);
        rUUID = [((__bridge NSString *) cfuuid) copy];
        CFRelease(cfuuid);
        NSLog(@"randomUUID uuid : %@", rUUID);
    }
    return rUUID;
}
#pragma mark - GetUUID End

#pragma mark - Save Start
/**
 * 保存uuid数据到keyChain
 */
- (void)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service
{
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

/**
 * 保存到本地存档
 */
- (void) setValue:(id)value forUserDefaultsKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:_uid forKey:_uidKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 存储uuid
 */
- (void)save {
    [self setValue:_uid forUserDefaultsKey:_uidKey];
    [self setValue:_uid forKeychainKey:_uidKey inService:_uidKey];
}
#pragma mark - Save End

#pragma mark - Read Start
/**
 * 从keyChain读取uuid
 */
- (NSString*) valueForKeychainKey:(NSString*)uidkey service:(NSString*)sericekey
{
    NSString* ret = nil;
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    keychainItem[(__bridge id)kSecAttrAccount] = uidkey;
    keychainItem[(__bridge id)kSecAttrService] = sericekey;
    keychainItem[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;//kSecReturnData
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    
    NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:keychainItem];
    NSMutableDictionary *outDictionary = nil;
    if (SecItemCopyMatching((CFDictionaryRef)tempQuery, (CFTypeRef)&outDictionary) == noErr){//6
        NSData* data = [outDictionary objectForKey:(__bridge id)kSecValueData];
        if (data != nil){
            ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"valueForKeychainKey uuid : %@", ret);
        }
    }
    return ret;
}

/**
 * 从本地读取uuid
 */
- (NSString*) valueForUserDefaultsKey : (NSString*) uidKey
{
    NSString* ret  = nil;
    if (uidKey != nil){
        ret = [[NSUserDefaults standardUserDefaults] stringForKey:uidKey];
        if ([ret isEqualToString:@""]){
            ret = nil;
        }
    }
    return ret;
}
#pragma mark - Read End
@end


@implementation No2UUID
+ (NSString* )no2UUID
{
    return [[No2UDIDManager sharedInstance] uuid];
}

@end
