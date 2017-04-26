//
//  DanmakuInputView.m
//  openGLDemo
//
//  Created by 方阳 on 17/3/21.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "DanmakuInputView.h"

@interface DanmakuInputView()<UITextFieldDelegate>

@property (nonatomic,strong) UITextField* inputTextField;

@end

@implementation DanmakuInputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        self.inputTextField = [[UITextField alloc] initWithFrame:self.bounds];
        [self addSubview:self.inputTextField];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.inputTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.inputTextField.returnKeyType = UIReturnKeyDone;
        self.inputTextField.enablesReturnKeyAutomatically = YES;
        self.inputTextField.delegate = self;
        [self observNotifications];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if( self.inputTextField )
    {
        return [self.inputTextField becomeFirstResponder];
    }
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark utility methods
- (void)observNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification handler
- (void)keyboardWillShow:(NSNotification*)notification;
{
//    CGFloat animationTime = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rawKeyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if( rawKeyboardRect.size.height )
    {
        CGRect frame = self.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - rawKeyboardRect.size.height - frame.size.height - 8;
        self.frame = frame;
        self.hidden = NO;
    }
}

- (void)keyboardWillHide:(NSNotification*)notification;
{
    CGRect frame = self.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height - 8;
    self.frame = frame;
    self.hidden = YES;
}

#pragma mark uitextfielddelegate
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    
//}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    BLOCK_INVOKE(self.danmakuBlock, textField.text);
    self.inputTextField.text = nil;
    [self.inputTextField resignFirstResponder];
    return YES;
}
@end
