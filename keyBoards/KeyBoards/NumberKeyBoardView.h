//
//  NumberKeyBoardView.h
//  renpindai
//
//  Created by QQQ on 15/7/7.
//  Copyright (c) 2015年 Enniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyBoardView.h"

FOUNDATION_EXPORT NSString *const kNumberKeyBoardEditNotification;

@protocol NumberKeyBoardViewDeleagte <NSObject>
@optional
-(BOOL)numberTextFiled:(UITextField*)textFiled changeInRange:(NSRange)range withString:(NSString*)string;
-(void)numberTextFiledReturn:(UITextField*)textFiled;
@end

@interface NumberKeyBoardView : UIView

@property (nonatomic ,assign) NSInteger maxLength; //default 0 
@property (nonatomic, weak) UITextField *textFiled;

@property (nonatomic, assign) BOOL textFiledWillNotFristResponder; //不是作为textFiled的inputView传入
@property (nonatomic ,assign) id <NumberKeyBoardViewDeleagte> delegate;

+(NumberKeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField;
@end