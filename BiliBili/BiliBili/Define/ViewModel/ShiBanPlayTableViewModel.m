//
//  ShiBanPlayTableViewModel.m
//  BiliBili
//
//  Created by apple-jd44 on 15/11/26.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "ShiBanPlayTableViewModel.h"
#import "ShinBanNetManager.h"
#import "ShiBanPlayTableModel.h"
@interface ShiBanPlayTableViewModel ()
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<ShiBanPlayTableDateModel*>*>* list;
/**
 *  日期偏移值
 */
@property (nonatomic, strong) NSString* dayOffset;
//@property (nonatomic, strong) NSDictionary* weekList;
@end

@implementation ShiBanPlayTableViewModel
- (NSString*)titleForRow:(NSInteger)row section:(NSInteger)section{
    return [self modelForRow:row section:section].title;
}
- (NSString*)newEpisodeForRow:(NSInteger)row section:(NSInteger)section{
    return [self modelForRow:row section:section].bgmcount;
}

- (ShiBanPlayTableDateModel*)modelForRow:(NSInteger)row section:(NSInteger)section{
    return [self listForSection: section][row];
}

- (NSArray*)listForSection:(NSInteger)section{
    return self.list[[self changeWeek: section]];
}

- (NSInteger)episodeCountForSection:(NSInteger)section{
    return [self listForSection:section].count;
}

- (NSInteger)sectionCount{
    return self.list.count;
}

- (NSString*)sectionTitleForSection:(NSInteger)section{
    return [self changeWeek: section];
}

/**
 *  根据偏移星期返回实际星期
 */
- (NSString*)changeWeek:(NSInteger)week{
    if (week == 7) {
        return @"-1";
    }
    return [NSString stringWithFormat:@"%ld", (week + self.dayOffset.intValue) % 7];
}


- (void)refreshDataCompleteHandle:(void(^)(NSError *error))complete{
    [ShinBanNetManager getShiBanPlayTableCompletionHandler:^(ShiBanPlayTableModel* responseObj, NSError *error) {
        NSArray<ShiBanPlayTableDateModel*>* tempArr = responseObj.list;
        [self.list removeAllObjects];
        [tempArr enumerateObjectsUsingBlock:^(ShiBanPlayTableDateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.list[obj.weekday] == nil) {
                self.list[obj.weekday] = [NSMutableArray array];
            }
            [self.list[obj.weekday] addObject: obj];
            
        }];
        complete(error);
    }];
}

#pragma mark - 懒加载
- (NSString *)dayOffset{
	if(_dayOffset == nil) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_cn"]];
        [formatter setDateFormat:@"EEE"];
		_dayOffset = @{@"周一":@"1",@"周二":@"2",@"周三":@"3",@"周四":@"4",@"周五":@"5",@"周六":@"6",@"周日":@"0"}[[formatter stringFromDate: date]];
	}
	return _dayOffset;
}

//- (NSDictionary *)weekList{
//	if(_weekList == nil) {
//        _weekList = @{@"1":@"周一",@"2":@"周二",@"3":@"周三",@"4":@"周四",@"5":@"周五",@"6":@"周六",@"0":@"周日",@"-1":@"其它"};
//	}
//	return _weekList;
//}



- (NSMutableDictionary<NSString*,NSMutableArray<ShiBanPlayTableDateModel*>*> *)list{
	if(_list == nil) {
		_list = [[NSMutableDictionary<NSString*,NSMutableArray<ShiBanPlayTableDateModel*>*> alloc] init];
	}
	return _list;
}

@end
