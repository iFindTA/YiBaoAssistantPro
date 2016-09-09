//
//  PBEmojiPanel.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/2.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBEmojiPanel.h"

static const int PB_EMOJI_BTN_WIDTH                     =       35;
static const int PB_EMOJI_COL_NUMS                      =       8;//几列
static const int PB_EMOJI_ROW_NUMS                      =       3;//几行
static const int PB_EMOJI_PAGECONTROL_HEIGHT            =       20;
static const int PB_EMOJI_SEGMENT_HEIGHT                =       30;

@interface PBEmojiPanel ()<UIScrollViewDelegate>
//表情emoji字典
@property (nonatomic, strong) NSDictionary *emojiDict;
//表情scroller
@property (nonatomic, strong) UIScrollView *emojiScroller;
@property (nonatomic, strong) UIView *container;
//pageControl
@property (nonatomic, strong) UIPageControl *emojiPageControl;
//segmentControl
@property (nonatomic, assign) NSUInteger curIndex;
@property (nonatomic, strong) UISegmentedControl *emojiSegmenter;
//发送按钮
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation PBEmojiPanel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    
    //self.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
    [self addSubview:self.sendBtn];
    [self addSubview:self.emojiSegmenter];
    
    [self addSubview:self.emojiPageControl];
        
    [self addSubview:self.emojiScroller];
    
    [self.emojiScroller addSubview:self.container];
    
    weakify(self)
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.right.bottom.equalTo(self);
        make.size.equalTo(CGSizeMake(50, PB_EMOJI_SEGMENT_HEIGHT));
    }];
    [self.emojiSegmenter mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.left.bottom.equalTo(self);
        make.right.equalTo(self.sendBtn.mas_left);
        make.height.equalTo(PB_EMOJI_SEGMENT_HEIGHT);
    }];
    [self.emojiPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.emojiSegmenter.mas_top);
        make.height.equalTo(PB_EMOJI_PAGECONTROL_HEIGHT);
    }];
    [self.emojiScroller mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.emojiPageControl.mas_top);
    }];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self.emojiScroller);
        make.height.equalTo(self.emojiScroller);
    }];
    self.curIndex = 0;
    self.emojiSegmenter.selectedSegmentIndex = self.curIndex;
    [self refreshEmojiKeyboardForIndex:self.curIndex];
}

- (void)clearContanier {
    NSArray *subviews = [self.container subviews];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    weakify(self)
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self.emojiScroller);
        make.height.equalTo(self.emojiScroller);
    }];
}

- (void)refreshEmojiKeyboardForIndex:(NSUInteger)idx {
    [self clearContanier];
    //表情
    NSString *mKey = [self getEmojiKey4Index:idx];
    NSArray *emojis = [self.emojiDict objectForKey:mKey];
    NSUInteger mCounts = emojis.count;
    NSUInteger mPageCounts = [self getPageCounts4EmojiCount:mCounts];
    //NSLog(@"一共%zd页emoji表情",mPageCounts);
    self.emojiPageControl.numberOfPages = mPageCounts;
    
    //每页的表情
    UIView *mLastLayout = nil;
    for (int i = 0; i < mPageCounts; i++) {
        UIView *mPage = [self getPageComponent4PageIndex:i];
        [self.container addSubview:mPage];
        weakify(self)
        [mPage mas_makeConstraints:^(MASConstraintMaker *make) {
            strongify(self)
            make.top.bottom.equalTo(self.emojiScroller);
            make.left.equalTo(self.emojiScroller).offset(PBSCREEN_WIDTH*i);
            make.width.equalTo(PBSCREEN_WIDTH);
        }];
        
        mLastLayout = mPage;
    }
    
    [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(mLastLayout.mas_right);
    }];
}

#pragma mark -- getter methods

- (NSString *)getEmojiKey4Index:(NSUInteger)idx {
    NSString *mKey = nil;
    if (idx == 0) {
        mKey = @"People";
    } else if (idx == 1) {
        mKey = @"Objects";
    } else if (idx == 2) {
        mKey = @"Nature";
    } else if (idx == 3) {
        mKey = @"Places";
    } else if (idx == 4) {
        mKey = @"Symbols";
    } else if (idx == 5) {
        mKey = @"";
    }
    return mKey;
}

- (NSUInteger) getPageCounts4EmojiCount:(NSUInteger)counts {
    NSUInteger mCounts = 0;
    
    NSUInteger onePageCounts = PB_EMOJI_ROW_NUMS*PB_EMOJI_COL_NUMS - 1;
    mCounts = counts / onePageCounts;
    if (counts % onePageCounts != 0) {
        mCounts += 1;
    }
    
    return mCounts;
}

- (UIView *)getPageComponent4PageIndex:(NSUInteger)idx {
    CGFloat mWidth = pb_autoResize(PB_EMOJI_BTN_WIDTH, @"6");
    CGFloat mDownHeight = PB_EMOJI_PAGECONTROL_HEIGHT+PB_EMOJI_SEGMENT_HEIGHT;
    CGFloat mHDistance = (PBSCREEN_WIDTH-mWidth*PB_EMOJI_COL_NUMS-PB_BOUNDARY_MARGIN*2)/(PB_EMOJI_COL_NUMS-1);
    CGFloat mVDistance = (PB_CHAT_KEYBOARD_HEIGHT-mDownHeight-PB_BOUNDARY_OFFSET*2-PB_EMOJI_ROW_NUMS*mWidth)/(PB_EMOJI_ROW_NUMS-1);
    CGRect bounds = CGRectMake(0, 0, PBSCREEN_WIDTH, PB_CHAT_KEYBOARD_HEIGHT-mDownHeight);
    UIView *mPage = [[UIView alloc] initWithFrame:bounds];
    mPage.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
    NSString *mKey = [self getEmojiKey4Index:self.curIndex];
    NSArray *emojis = [self.emojiDict objectForKey:mKey];
    NSUInteger mMaxCounts = emojis.count;
    //一页多少个emoji
    int onePageMaxCounts = PB_EMOJI_ROW_NUMS*PB_EMOJI_COL_NUMS;
    int onePageCounts = onePageMaxCounts - 1;
    int startIndex = (int)idx * onePageMaxCounts;
    if (startIndex > 0) {
        startIndex -= idx;
    }
    int endIndex = startIndex + onePageCounts;
    UIFont *font = PBSysFont(PBFontTitleSize*2);
    for (int i = startIndex; i < endIndex; i ++) {
        if (i >= mMaxCounts) {
            break;
        }
        NSString *emoji = emojis[i];
        int mPageIndex = i-startIndex;
        NSUInteger mCol = mPageIndex % PB_EMOJI_COL_NUMS;
        NSUInteger mRow = mPageIndex / PB_EMOJI_COL_NUMS;
        CGRect mBounds =CGRectMake(PB_BOUNDARY_MARGIN + (mWidth+mHDistance)*mCol, PB_BOUNDARY_OFFSET + (mWidth+mVDistance)*mRow, mWidth, mWidth);
        UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //emojiBtn.backgroundColor = [UIColor redColor];
        emojiBtn.tag = i;
        emojiBtn.frame = mBounds;
        emojiBtn.exclusiveTouch = true;
        emojiBtn.titleLabel.font = font;
        [emojiBtn setTitle:emoji forState:UIControlStateNormal];
        [emojiBtn addTarget:self action:@selector(emojiBtnTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        [mPage addSubview:emojiBtn];
    }
    
    //退格键
    UIColor *color = [UIColor pb_colorWithHexString:@"858585"];
    UIImage *backImg = [UIImage pb_iconFont:nil withName:@"\U0000e617" withSize:mWidth/PBSCREEN_SCALE withColor:color];
    CGRect mBounds =CGRectMake(PB_BOUNDARY_MARGIN + (mWidth+mHDistance)*(PB_EMOJI_COL_NUMS-1), PB_BOUNDARY_OFFSET + (mWidth+mVDistance)*(PB_EMOJI_ROW_NUMS-1), mWidth, mWidth);
    UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //emojiBtn.backgroundColor = [UIColor redColor];
    emojiBtn.frame = mBounds;
    emojiBtn.exclusiveTouch = true;
    emojiBtn.titleLabel.font = font;
    [emojiBtn setBackgroundImage:backImg forState:UIControlStateNormal];
    [emojiBtn addTarget:self action:@selector(emojiBackwardTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    [mPage addSubview:emojiBtn];
    
    return mPage;
}

- (NSDictionary *)emojiDict {
    if (!_emojiDict) {
        NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"EmojisList" ofType:@"plist"];
        _emojiDict = [NSDictionary dictionaryWithContentsOfFile:emojiPath];
    }
    return _emojiDict;
}

- (UIScrollView *)emojiScroller {
    if (!_emojiScroller) {
        _emojiScroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        _emojiScroller.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
        _emojiScroller.showsVerticalScrollIndicator = false;
        _emojiScroller.showsHorizontalScrollIndicator = false;
        _emojiScroller.pagingEnabled = true;
        _emojiScroller.delegate = self;
        _emojiScroller.alwaysBounceHorizontal = true;
    }
    return _emojiScroller;
}

- (UIView *)container {
    if (!_container) {
        UIView *container = [[UIView alloc] init];
        container.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
        _container = container;
    }
    return _container;
}

- (UIPageControl *)emojiPageControl {
    if (!_emojiPageControl) {
        NSString *tintColor = @"D6D6D6";
        NSString *currentColor = @"878787";
        _emojiPageControl = [[UIPageControl alloc] init];
        _emojiPageControl.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
        _emojiPageControl.pageIndicatorTintColor = [UIColor pb_colorWithHexString:tintColor];
        _emojiPageControl.currentPageIndicatorTintColor = [UIColor pb_colorWithHexString:currentColor];
    }
    return _emojiPageControl;
}

- (UISegmentedControl *)emojiSegmenter {
    if (!_emojiSegmenter) {
        //segment.tintColor = [UIColor clearColor];//去掉颜色,现在整个segment都看不见
        UIColor *tintColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:PBSysFont(PBFontTitleSize),NSForegroundColorAttributeName: tintColor};
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:PBSysFont(PBFontTitleSize),NSForegroundColorAttributeName: [UIColor whiteColor]};
        NSArray *items = @[@"😄",@"🎍",@"🐶",@"🏠",@"🔠"];
        _emojiSegmenter = [[UISegmentedControl alloc] initWithItems:items];
        _emojiSegmenter.selectedSegmentIndex = 0;
        //_emojiSegmenter.momentary = true;//选择之后复原
        _emojiSegmenter.tintColor = tintColor;
        [_emojiSegmenter setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        [_emojiSegmenter setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        [_emojiSegmenter addTarget:self action:@selector(emojiSegmentDidChangeEvent) forControlEvents:UIControlEventValueChanged];
    }
    return _emojiSegmenter;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        UIFont *font = PBSysFont(PBFontSubSize);
        UIColor *text_e = [UIColor pb_colorWithHexString:@"FFFFFF"];
        UIColor *text_d = [UIColor pb_colorWithHexString:@"767981"];
        //UIColor *bg_e = [UIColor pb_colorWithHexString:@"007AFF"];
        UIColor *bg_d = [UIColor pb_colorWithHexString:@"ACB3BC"];
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.enabled = false;
        _sendBtn.exclusiveTouch = true;
        _sendBtn.titleLabel.font = font;
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitle:@"发送" forState:UIControlStateDisabled];
        [_sendBtn setTitleColor:text_e forState:UIControlStateNormal];
        [_sendBtn setTitleColor:text_d forState:UIControlStateDisabled];
        [_sendBtn setBackgroundColor:bg_d];
        [_sendBtn addTarget:self action:@selector(sendBtnTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

#pragma mark -- scrollView Delegate

- (NSUInteger)currentPageIdx {
    float offset = self.emojiScroller.contentOffset.x;
    CGFloat width = floorf(CGRectGetWidth(self.emojiScroller.bounds));
    NSUInteger idx = (offset + (width * 0.5)) / width;
    return idx;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.emojiPageControl.currentPage = [self currentPageIdx];
}

#pragma mark -- 外部控制是否激活发送按钮
- (void)enableEmojiKeyboardSendState:(BOOL)enable {
    self.sendBtn.enabled = enable;
    UIColor *bg_e = [UIColor pb_colorWithHexString:@"007AFF"];
    UIColor *bg_d = [UIColor pb_colorWithHexString:@"AEB3BE"];
    self.sendBtn.backgroundColor = enable?bg_e:bg_d;
}

#pragma mark -- 表情点击事情

- (void)emojiBtnTouchEvent:(UIButton *)btn {
    /*
    NSUInteger __tag = btn.tag;
    NSArray *emojis = [self.emojiDict objectForKey:@"People"];
    if (__tag >= emojis.count) {
        return;
    }
    NSString *emoji = emojis[__tag];
     */
    NSString *emoji = btn.titleLabel.text;
    
    if (_delegate && [_delegate respondsToSelector:@selector(emojiPanel:didSelectEmoji:)]) {
        [self.delegate emojiPanel:self didSelectEmoji:emoji];
    }
}

- (void)emojiBackwardTouchEvent {
    if (_delegate && [_delegate respondsToSelector:@selector(emojiPanelDidSelectBackward:)]) {
        [self.delegate emojiPanelDidSelectBackward:self];
    }
}

- (void)emojiSegmentDidChangeEvent {
    NSUInteger tmpIdx = self.emojiSegmenter.selectedSegmentIndex;
    if (tmpIdx == self.curIndex) {
        return;
    }
    self.curIndex = tmpIdx;
    [self refreshEmojiKeyboardForIndex:tmpIdx];
}
//发送按钮点击
- (void)sendBtnTouchEvent {
    if (_delegate && [_delegate respondsToSelector:@selector(emojiPanelDidSelectSendEvent:)]) {
        [self.delegate emojiPanelDidSelectSendEvent:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
