//
//  PBSessionCell.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/25.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

/**
 *  @brief swipe action call back
 *
 *  @attention  why callback block should pass the cell? cause of when you delete one cell in path, then
 *  delete a cell in the same path, the default indexPath should be incorrect!!! (cause of you are using the dataSource's indexPath which is not correct sometime!)
 *
 *  @param replyAction wether is read/unread action
 *  @param swipeCell   the cell
 */
typedef void(^PBSessionActionEvent)(BOOL replyAction, MGSwipeTableCell *swipeCell);

@class PBSession;
@interface PBSessionCell : MGSwipeTableCell

- (void)updateContent4Source:(PBSession *)session;

- (void)handleSessionMoreAction:(PBSessionActionEvent)event;

@end
