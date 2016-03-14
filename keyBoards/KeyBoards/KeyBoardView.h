//
//  KeyBoardView.h
//  Freshen
//
//  Created by QQQ on 15/6/23.
//  Copyright (c) 2015年 QQQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+SixLetter.h"

FOUNDATION_EXPORT NSString *const kKeyBoardTextFiledEditNotification;
FOUNDATION_EXPORT CGFloat const kKeyBoardHeight;

@protocol KeyBoardViewDeleagte <NSObject>
@optional
-(BOOL)textFiled:(UITextField*)textFiled changeInRange:(NSRange)range withString:(NSString*)string;
-(void)textFieldReturn:(UITextField*)textFiled;
@end

@interface KeyBoardView : UIView

@property (nonatomic, weak) UITextField *textFiled;
@property (nonatomic ,assign) id <KeyBoardViewDeleagte> delegate;
@property (nonatomic, assign) BOOL canInputZero;

+(KeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField;
+(KeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField canZero:(BOOL)canZero;
@end