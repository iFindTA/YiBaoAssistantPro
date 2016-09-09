//
//  YBSearchProfiler.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "YBSearchProfiler.h"
#import "PBConstants.h"

@interface YBSearchProfiler ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) YBSearchEvent event;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *searchTable;

@end

@implementation YBSearchProfiler

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = PBSysFont(PBFontTitleSize);
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 0;
    label.text = @"好服务，马上搜出来...";
    [self addSubview:label];
    weakify(self)
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self);
    }];
    
    if (self.searchTable != nil) {
        return;
    }
    //table
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    table.hidden = true;
    [self addSubview:table];
    self.searchTable = table;
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self);
    }];
    
    //TODO:test for data
    int mCount = 30;
    for (int i = 0; i < mCount; i++) {
        NSString *name = PBFormat(@"name:%zd",i);
        [self.dataSource addObject:name];
    }
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (void)handleSearchMsgEvent:(YBSearchEvent)event {
    _event = [event copy];
}

- (void)beginBecomeFirstResponder {
    self.searchTable.hidden = false;
}

- (void)endFirstResponder {
    self.searchTable.hidden = true;
}

- (void)searchKeywordDidChange2:(NSString *)key {
    
    //TODO:策略－－输入变化后延迟1秒钟搜索
    self.searchTable.hidden = PBIsEmpty(key);
    [self.searchTable reloadData];
    
//    NSString * searchtext = searchController.searchBar.text;
//    NSArray * searchResults = [self.msgQueue filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * evaluatedObject, NSDictionary *bindings) {
//        BOOL result = NO;
//        if ([evaluatedObject hasSuffix:searchtext]) {
//            result = YES;
//        }
//        return result;
//    }]];
}

#pragma mark -- UITableView Datasource && Delegate

static NSUInteger MSG_CELL_HEIGHT               =       50;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger mCount = self.dataSource.count;
    NSLog(@"count:%zd",mCount);
    return mCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MSG_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idendifier = @"msgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idendifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idendifier];
    }
   
    NSUInteger __row_idx = [indexPath row];
    NSString *tmp = self.dataSource[__row_idx];
    cell.textLabel.text = tmp;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_event) {
        _event(@"ss");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
