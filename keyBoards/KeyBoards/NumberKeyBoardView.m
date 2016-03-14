//
//  NumberKeyBoardView.m
//  renpindai
//
//  Created by QQQ on 15/7/7.
//  Copyright (c) 2015年 Enniu. All rights reserved.
//

#import "NumberKeyBoardView.h"

NSString *const kNumberKeyBoardEditNotification = @"kNumberKeyBoardEditNotification";

@implementation NumberKeyBoardView

-(void)dealloc
{
    NSLog(@"%@ dealloc",[self class]);
}


+(NumberKeyBoardView*)initKeyBoardViewWithTarget:(id)target textFiled:(UITextField*)textField;
{
    NumberKeyBoardView *keyBoard = [[NumberKeyBoardView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kKeyBoardHeight)];
    keyBoard.delegate = target;
    keyBoard.backgroundColor = [UIColor whiteColor];
    [keyBoard initKeyView];
    keyBoard.textFiled = textField;
    return keyBoard;
}

- (void)initKeyView
{
    CGFloat b_width = [UIScreen mainScreen].bounds.size.width/3;
    CGFloat b_height = kKeyBoardHeight/4;
    
    for (int i = 0; i < 12; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"keyboard_backcolor_nomal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"keyboard_backcolor_height"] forState:UIControlStateHighlighted];
        button.tag = i+1;
        button.titleLabel.font = [UIFont systemFontOfSize:28.f];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        if( i == 9)
        {
            button.frame = CGRectMake(0, 3*b_height, b_width, b_height);
            [button setTitle:@"确定" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:20.f];
            [button setTitleColor:[UIColor colorWithSixLetter:@"60ABFF"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(keyBoardReturn) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (i == 11)
        {
            button.frame = CGRectMake(2*b_width, 3*b_height, b_width, b_height);
            [button setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteNumber) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteNumberWithLongPress)];
            longPress.minimumPressDuration = 0.8;
            [button addGestureRecognizer:longPress];
        }
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            int row = i/3;
            int line = i%3;
            button.frame = CGRectMake(b_width*line, b_height*row, b_width, b_height);
            
            //数字0
            if (i == 10)
            {
                [button setTitle:@"0" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(numberSelect:) forControlEvents:UIControlEventTouchUpInside];
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
    
    for (int i = 0; i < 2; i++)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(b_width*(i+1), 0, 0.5f, kKeyBoardHeight)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
    }
    
    for (int i = 0; i < 4; i ++)
    {
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, b_height*i, i == 0 || i == 2 ? 4*b_width : 3*b_width, 0.5f)];
        row.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:row];
    }
}

#pragma mark IBAction Methods
-(void)numberSelect:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *string = @"";
    switch (btn.tag) {
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
    if ([self.delegate respondsToSelector:@selector(numberTextFiled:changeInRange:withString:)])
    {
        BOOL canChange = [self.delegate numberTextFiled:_textFiled changeInRange:range withString:text];
        if (!canChange)
        {
            return;
        }
    }
    
    NSMutableString *textString = [[NSMutableString alloc] initWithString:_textFiled.text];
    if (range.length == 0)
    {
        if (_textFiled.text.length >=  _maxLength && _maxLength > 0)
        {
            return;
        }
        if (_textFiledWillNotFristResponder)
        {
            [textString appendString:text];
            _textFiled.text = textString;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
        }
        else
        {
            [textString insertString:text atIndex:range.location];
            _textFiled.text = textString;
            [self textFiledSetSelectRange:NSMakeRange(range.location + text.length, 0)];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
        }
    }
    else
    {
        [textString replaceCharactersInRange:range withString:text];
        _textFiled.text = textString;
        [self textFiledSetSelectRange:NSMakeRange(range.location + text.length, 0)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
    }
}

-(void)keyBoardReturn
{
    [_textFiled resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(numberTextFiledReturn:)])
    {
        [self.delegate numberTextFiledReturn:_textFiled];
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
            if (_textFiledWillNotFristResponder && _textFiled.text.length > 0)
            {
                NSRange deleteRange = NSMakeRange(_textFiled.text.length -1, 1);
                NSString *textFiledString = _textFiled.text;
                NSString *newString = [textFiledString stringByReplacingCharactersInRange:deleteRange withString:@""];
                _textFiled.text = newString;
                NSRange selectRange = NSMakeRange(selectrange.location -1, 0);
                [self textFiledSetSelectRange:selectRange];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
            }
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kNumberKeyBoardEditNotification object:nil];
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