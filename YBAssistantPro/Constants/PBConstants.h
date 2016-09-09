//
//  PBConstants.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#ifndef PBConstants_h
#define PBConstants_h

static const int PB_SIDE_OFF_WIDTH                  =       60;
static const int PB_BOUNDARY_OFFSET                 =       10;
static const int PB_BOUNDARY_MARGIN                 =       16;
static const int PB_CONTENT_MARGIN                  =       9;
static const int PB_NAVIBAR_HEIGHT                  =       64;
static const int PB_NAVIBAR_ITEM_SIZE               =       31;
static const int PB_DESC_COUNTS                     =       60;
static const int PB_CUSTOM_BTN_HEIGHT               =       40;
static const int PB_CUSTOM_TFD_HEIGHT               =       40;
static const int PB_CUSTOM_LAB_HEIGHT               =       21;
static const int PB_CUSTOM_CELL_HEIGHT              =       55;
static const int PB_CUSTOM_LINE_HEIGHT              =       1;
static const int PB_FEEDBACK_CRS_MAX                =       300;
static const int PB_CORNER_RADIUS                   =       4;
static const int PB_REFRESH_INTERVAL                =       600;
static const int PB_REFRESH_PAGESIZE                =       20;
static const int PB_TEXT_PADDING                    =       8;

static const int PB_NICK_MIN_LEN                    =       2;
static const int PB_NICK_MAX_LEN                    =       10;
static const int PB_PASSWD_MIN_LEN                  =       6;
static const int PB_PASSWD_MAX_LEN                  =       16;

//font
static const CGFloat PBFontTitleSize                =       15.f;
static const CGFloat PBFontSubSize                  =       13.f;

// global theme
static NSString * PB_BASE_BG_HEX                    =       @"#FFFFFF";

//navi
static NSString * PB_NAVIBAR_TINT_HEX               =       @"#FF423A";
static NSString * PB_TABBAR_TINT_HEX                =       @"#FF423A";
static NSString * PB_BUTTON_IN_TINT_HEX             =       @"#00B050";
static NSString * PB_BUTTON_EN_TINT_HEX             =       @"#2ED865";
static NSString * PB_BTN_TITLE_IN_TINT_HEX          =       @"#EFF0F2";
static NSString * PB_NAVI_ICON_BACK                 =       @"\U0000e600";
static NSString * PB_NAVI_ICON_CANCEL               =       @"\U0000e605";

//seperate line
static const NSString * PB_SEPERATE_LINE_HEX        =       @"#DCDEE6";

//regix
static NSString * PB_PASSWD_REGEXP                  =       @"^[A-Za-z0-9!^@#$`~%&*/_-{}()<>\":;,.']+$";
static NSString * PB_PHONE_REGEXP                   =       @"^(1[3-9][0-9](?: ))(\\d{4}(?: )){2}$";
//usr
static NSString * PB_USR_AUTO_LOGOUT_KEY            =       @"PBUSRAUTOLOGOUTKEY";
static NSString * PB_UI_DESIGN_REFRENCE             =       @"6";

//scheme
static NSString * PB_SAFE_SCHEME                    =       @"YiBao";

//chat
static const int PB_CHAT_TOOLBAR_HEIGHT             =       40;
static const int PB_CHAT_KEYBOARD_HEIGHT            =       216;
static const int PB_CHAT_TIME_PROMOT_FONT           =       11;
static const int PB_CHAT_CONTENT_FONT               =       14;

#endif /* PBConstants_h */
