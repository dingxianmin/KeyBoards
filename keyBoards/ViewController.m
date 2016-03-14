//
//  ViewController.m
//  keyBoards
//
//  Created by invoker on 16/3/8.
//  Copyright © 2016年 QQQ. All rights reserved.
//

#import "ViewController.h"
#import "KeyBoardView.h"
#import "NumberKeyBoardView.h"

@interface ViewController ()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFiled 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
         textField.inputView = [KeyBoardView initKeyBoardViewWithTarget:self textFiled:textField canZero:YES];
    } else if (textField.tag == 2) {
        textField.inputView = [NumberKeyBoardView initKeyBoardViewWithTarget:nil textFiled:textField];
    }
    return YES;
}
@end
