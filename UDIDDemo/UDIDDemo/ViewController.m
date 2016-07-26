//
//  ViewController.m
//  UDIDDemo
//
//  Created by zhaojun on 16/7/26.
//  Copyright © 2016年 zhaojun. All rights reserved.
//

#import "ViewController.h"
#import "No2UUID.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"UUID : %@", [No2UUID no2UUID]);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
