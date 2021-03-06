//
//  ShinBanViewModel.h
//  BiliBili
//
//  Created by apple-jd44 on 15/10/28.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "BaseViewModel.h"
@class MoreViewShinBanDataModel, RecommentShinBanDataModel;
@interface ShinBanViewModel : BaseViewModel
@property (nonatomic, strong) NSMutableArray<MoreViewShinBanDataModel*>* moreViewList;
@property (nonatomic, strong) NSMutableArray<RecommentShinBanDataModel*>* recommentList;

- (NSInteger)moreViewListCount;
- (NSInteger)recommentListCount;

- (NSURL*)moreViewPicForRow:(NSInteger)row;
- (NSString*)moreViewPlayForRow:(NSInteger)row;
- (NSString*)moreViewTitleForRow:(NSInteger)row;
- (MoreViewShinBanDataModel*)moreViewModelForRow:(NSInteger)row;

- (NSURL*)commendCoverForRow:(NSInteger)row;
- (NSString*)commendTitileForRow:(NSInteger)row;


- (void)refreshDataCompleteHandle:(void(^)(NSError *error))complete;
- (void)getMoreDataCompleteHandle:(void(^)(NSError *error))complete;
@end
