//
//  AVInfoViewController.h
//  BiliBili
//
//  Created by apple-jd44 on 15/11/1.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVDataModel;
@interface AVInfoViewController : UIViewController

- (void)setWithModel:(AVDataModel*)model section:(NSString*)section;
@end
