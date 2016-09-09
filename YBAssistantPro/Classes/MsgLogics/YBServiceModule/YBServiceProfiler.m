//
//  YBServiceProfiler.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/4.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "YBServiceProfiler.h"

@interface YBServiceProfiler ()

@end

@implementation YBServiceProfiler

- (void)dealloc {
    
}

- (BOOL)canOpenedByNativeUrl:(NSURL *)url {
    return true;
}

- (id)initWithParams:(NSDictionary *)aDict {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"壹宝服务";
    //left
    UIBarButtonItem *spacer = [self barSpacer];
    UIBarButtonItem *menuBar = [self barWithIcon:PB_NAVI_ICON_CANCEL withTarget:self withSelector:@selector(popUpLayer)];
    self.navigationItem.leftBarButtonItems = @[spacer, menuBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
