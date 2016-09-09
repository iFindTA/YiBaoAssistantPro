//
//  ViewController.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect bounds = CGRectMake(100, 100, 200, 50);
    NSLog(@"bounds:%@",NSStringFromCGRect(bounds));
    
    UILabel *label = [[UILabel alloc] initWithFrame:bounds];
    label.text = @"test for gitflow!";
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
