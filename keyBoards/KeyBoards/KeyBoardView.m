//
//  KeyBoardView.m
//  Freshen
//
//  Created by QQQ on 15/6/23.
//  Copyright (c) 2015年 QQQ. All rights reserved.
//

#import "KeyBoardView.h"

NSString *const kKeyBoardTextFiledEditNotification = @"kKeyBoardTextFiledEditNotification";
CGFloat const kKeyBoardHeight = 216.f;

@implementation KeyBoardView

-(void)dealloc
{
    NSLog(@"%@ dealloc",[self class]);
}

+(KeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField;
{
    
    KeyBoardView *keyBoard = [[KeyBoardView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kKeyBoardHeight)];
    keyBoard.delegate = target;
    [keyBoard setBackgroundColor:[UIColor whiteColor]];
    [keyBoard initKeyView];
    keyBoard.textFiled = textField;
    [keyBoard changeSureColor];
    return keyBoard;
}

+(KeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField canZero:(BOOL)canZero
{
    KeyBoardView *keyBoard = [[KeyBoardView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kKeyBoardHeight)];
    keyBoard.delegate = target;
    [keyBoard setBackgroundColor:[UIColor whiteColor]];
    [keyBoard initKeyView];
    keyBoard.textFiled = textField;
    keyBoard.canInputZero = canZero;
    [keyBoard changeSureColor];
    return keyBoard;
}

-(void)initKeyView
{
    
    CGFloat b_width = [UIScreen mainScreen].bounds.size.width/4;
    CGFloat b_height = kKeyBoardHeight /4;
    
    for (int i = 0; i < 14; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i+1;
        [button.titleLabel setFont:[UIFont systemFontOfSize:24.f]];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        if( i == 12)
        {
            [button setBackgroundColor:[UIColor colorWithSixLetter:@"EFEFF4"]];
            [button setFrame:CGRectMake(3*b_width, 0, b_width, 2*b_height)];
            [button setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteNumber) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteNumberWithLongPress)];
            longPress.minimumPressDuration = 0.8;
            [button addGestureRecognizer:longPress];
        }
        else if (i == 13)
        {
            [button setBackgroundColor:[UIColor colorWithSixLetter:@"EFEFF4"]];
            [button setFrame:CGRectMake(3*b_width, 2*b_height, b_width, 2*b_height)];
            [button setTitle:@"确定" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
            [button setBackgroundColor:[UIColor colorWithSixLetter:@"60ABFF"]];
            [button setTitleColor:[UIColor colorWithSixLetter:@"FFFFFF" alpha:0.3f] forState:UIControlStateDisabled];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(keyBoardReturn) forControlEvents:UIControlEventTouchUpInside];
            [button setEnabled:NO];
        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"keyboard_backcolor_nomal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"keyboard_backcolor_height"] forState:UIControlStateHighlighted];
            int row = i/3;
            int line = i%3;
            [button setFrame:CGRectMake(b_width*line, b_height*row, b_width, b_height)];

            //小数点
            if (i == 9)
            {
                [button setTitle:@"." forState:UIControlStateNormal];
                [button addTarget:self action:@selector(numberSelect:) forControlEvents:UIControlEventTouchUpInside];
            }
            //数字0
            else if (i == 10)
            {
                [button setTitle:@"0" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(numberSelect:) forControlEvents:UIControlEventTouchUpInside];
            }
            //弹出键盘
            else if (i == 11)
            {
                [button setImage:[UIImage imageNamed:@"keyboard_return"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(keyBoarDisMiss) forControlEvents:UIControlEventTouchUpInside];
            }
            //数字键盘
            else
            {
                NSString *number = [NSString stringWithFormat:@"%d",i+1];
                [button setTitle:number forState:UIControlStateNormal];
                [button addTarget:self action:@selector(numberSelect:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self addSubview:button];
    }
    
    for (int i = 0; i < 3; i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(b_width*(i+1), 0, 0.5f, kKeyBoardHeight)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:line];
    }
    
    for (int i = 0; i < 4; i ++)
    {
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, b_height*i, i == 0 || i == 2 ? 4*b_width : 3*b_width, 0.5f)];
        [row setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:row];
    }
}

-(void)numberSelect:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *string = @"";
    switch (btn.tag) {
        case 10:
            string = @".";
            break;
        case 11:
            string = @"0";
            break;
        default:
            string = [NSString stringWithFormat:@"%ld",(long)btn.tag];
            break;
    }
    
    NSRange selectrange = [self textFiledSelectedRange];
    [self textFiledWillChangeText:string inRange:selectrange];
}

//补充逻辑判断
-(void)textFiledWillChangeText:(NSString*)text inRange:(NSRange)range
{
    if ([self.delegate respondsToSelector:@selector(textFiled:changeInRange:withString:)])
    {
        BOOL canChange = [self.delegate textFiled:_textFiled changeInRange:range withString:text];
        if (!canChange)
        {
            return;
        }
    }
    
    NSMutableString *textString = [[NSMutableString alloc] initWithString:_textFiled.text];
    if (range.length == 0)
    {
        if (range.location == 0)
        {
            if (self.canInputZero)
            {
                [textString insertString:text atIndex:range.location];
                
            }
            else if ([text isEqualToString:@"."] || [text isEqualToString:@"0"])
            {
                return;
            }
            else
            {
                [textString insertString:text atIndex:range.location];
            }
        }
        else
        {
            NSRange pointRange = [_textFiled.text rangeOfString:@"."];
            //包含标点
            if (pointRange.location != NSNotFound)
            {
                if ([text isEqualToString:@"."])
                {
                    return;
                }
                
                if (pointRange.location >= range.location)
                {
                    [textString insertString:text atIndex:range.location];
                }
                else
                {
                    NSString *pointLastString = [_textFiled.text substringFromIndex:pointRange.location];
                    if (pointLastString.length >= 3)
                    {
                        return;
                    }
                    else
                    {
                        [textString insertString:text atIndex:range.location];
                    }
                }
            }
            else
            {
                if ([text isEqualToString:@"."])
                {
                    if (_textFiled.text.length - range.location > 2)
                    {
                        return;
                    }
                    else
                    {
                        [textString insertString:text atIndex:range.location];
                    }
                }
                else
                {
                    [textString insertString:text atIndex:range.location];
                }
            }
        }
        _textFiled.text = textString;
        [self textFiledSetSelectRange:NSMakeRange(range.location + text.length, 0)];
        [self changeSureColor];
        [[NSNotificationCenter defaultCenter] postNotificationName:kKeyBoardTextFiledEditNotification object:nil];
    }
    else
    {
        //暂不支持
        return;
    }
}

-(void)changeSureColor
{
    UIButton *btn = (UIButton*)[self viewWithTag:14];
    if (_textFiled.text.length == 0)
    {
        [btn setEnabled:NO];
    }
    else
    {
        [btn setEnabled:YES];
    }
}

-(void)deleteNumber
{
    NSRange selectrange = [self textFiledSelectedRange];
    //未选中文本
    if (selectrange.length == 0)
    {
        if (selectrange.location == 0)
        {
            //并没有文本可以删除
            return;
        }
        else
        {
            //光标前一个
            NSRange deleteRange = NSMakeRange(selectrange.location -1, 1);
            NSString *textFiledString = _textFiled.text;
            NSString *newString = [textFiledString stringByReplacingCharactersInRange:deleteRange withString:@""];
            _textFiled.text = newString;
            NSRange selectRange = NSMakeRange(selectrange.location -1, 0);
            [self textFiledSetSelectRange:selectRange];
            [[NSNotificationCenter defaultCenter] postNotificationName:kKeyBoardTextFiledEditNotification object:nil];
            [self changeSureColor];
        }
    }
    //选中若干文本
    else
    {
        NSString *textFiledString = _textFiled.text;
        NSString *newString = [textFiledString stringByReplacingCharactersInRange:selectrange withString:@""];
        _textFiled.text = newString;
        NSRange selectRange = NSMakeRange(selectrange.location, 0);
        [self textFiledSetSelectRange:selectRange];
        [[NSNotificationCenter defaultCenter] postNotificationName:kKeyBoardTextFiledEditNotification object:nil];
        [self changeSureColor];
    }
}

-(void)deleteNumberWithLongPress
{
    NSString *oldString = _textFiled.text;
    if (oldString.length > 0)
    {
        NSRange range = NSMakeRange(0, _textFiled.text.length);
        NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:@""];
        [_textFiled setText:newString];
        [self changeSureColor];
        [[NSNotificationCenter defaultCenter] postNotificationName:kKeyBoardTextFiledEditNotification object:nil];
    }
}

-(void)keyBoarDisMiss
{
    [_textFiled resignFirstResponder];
}

-(void)keyBoardReturn
{
    [_textFiled resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(textFieldReturn:)])
    {
        [self.delegate textFieldReturn:_textFiled];
    }
}

#pragma mark UITextFiled-Extend
//textFiled 光标位置
- (NSInteger)textFiledRangeLocation
{
    UITextPosition* beginning = self.textFiled.beginningOfDocument;
    UITextRange* selectedRange = self.textFiled.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    const NSInteger location = [self.textFiled offsetFromPosition:beginning toPosition:selectionStart];
    return location;
}

//textFiled 选中的Range
- (NSRange)textFiledSelectedRange
{
    UITextPosition* beginning = self.textFiled.beginningOfDocument;
    UITextRange* selectedRange = self.textFiled.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [self.textFiled offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self.textFiled offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

//设置textFiled光标位置
-(void)textFiledSetSelectRange:(NSRange)range
{
    UITextPosition* beginning = self.textFiled.beginningOfDocument;
    UITextPosition* startPosition = [self.textFiled positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self.textFiled positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self.textFiled textRangeFromPosition:startPosition toPosition:endPosition];
    [self.textFiled setSelectedTextRange:selectionRange];
}
@end