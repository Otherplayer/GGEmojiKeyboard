//
//  GGInputView.m
//  GGEmojiKeyboard
//
//  Created by __无邪_ on 15/5/3.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGInputView.h"
#import "GGEmojiKeyboardView.h"

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

const  CGFloat  ButtonWidth = 64.0f;
const  CGFloat  Margin = 6.25f;
const  CGFloat  InputViewHeight = 36.5f;//36.5
static CGFloat  ViewHeight = InputViewHeight + Margin * 2;


NSString *const kHiddenKeyboardNotification = @"kHiddenKeyboardNotification";

@interface GGInputView ()<UITextViewDelegate>
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) GGEmojiKeyboardView *keyboardView;

@end

@implementation GGInputView{
    UIButton *leftButton;
    UIView *spv;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        // 顶部线条
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:line];
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark - Public
-(void)showInView:(UIView *)superView{
    [superView addSubview:self];
    spv = superView;
    [self registerNotification];
    [self setFrame:CGRectMake(0, superView.bounds.size.height - ViewHeight, ScreenWidth, ViewHeight)];
    [self setupInputView];
    [self setupFunctionView];
}

#pragma mark -
#pragma mark - Setup
- (void)setupInputView{
    
    UIFont *font = [UIFont systemFontOfSize:17];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(ButtonWidth, Margin, ScreenWidth - ButtonWidth * 2, InputViewHeight) textContainer:nil];
    self.textView.font = font;
    self.textView.scrollEnabled = NO;
    self.textView.delegate = self;
    self.textView.layer.cornerRadius = 4.0f;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth = 0.5f;
    
    [self addSubview:self.textView];
}

- (void)setupFunctionView{
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, (ViewHeight - 40) / 2, ButtonWidth - 10, 40)];
    [self addSubview:leftButton];
    [leftButton setBackgroundColor:[UIColor grayColor]];
    
    [leftButton addTarget:self
                   action:@selector(leftButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action
- (void)leftButtonAction:(id)sender{

    if (self.keyboardView.isShowing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView becomeFirstResponder];
        });
    }else{
        [self.textView resignFirstResponder];
    }
    
    [self altEmojiKeyboardShowState];
}

#pragma mark -
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    
    
    [self altInputViewShowState:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

#pragma mark - Notification

- (void)keyboardWillShowNotification:(NSNotification *)noti{
    if (_keyboardView && _keyboardView.isShowing) {
        [self altEmojiKeyboardShowState];
    }
    
    NSTimeInterval animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect currentRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = CGRectMake(0, ScreenHeight - ViewHeight - currentRect.size.height, ScreenWidth, ViewHeight);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    });
}

- (void)keyboardWillHideNotification:(NSNotification *)noti{

    NSTimeInterval animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:animationDuration + 0.01 animations:^{
            [self setFrame:CGRectMake(0, ScreenHeight - ViewHeight, ScreenWidth, ViewHeight)];
        }];
    });
}

- (void)hideEmojiKeyboardNotification:(NSNotification *)noti{
    if (self.keyboardView.isShowing) {
        [self altEmojiKeyboardShowState];
    }
}

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideEmojiKeyboardNotification:) name:kHiddenKeyboardNotification object:nil];
}


#pragma mark - Private

- (void)altInputViewShowState:(UITextView *)textView{
    CGFloat heightofTextView = [self contentofheight:textView.text];
    CGRect newSelfFrame = self.frame;
    CGFloat oldHeight = newSelfFrame.size.height;
    CGFloat newHeight = heightofTextView + Margin * 2;
    
    ViewHeight = newHeight;
    
    newSelfFrame.size.height = newHeight;
    newSelfFrame.origin.y = newSelfFrame.origin.y - newHeight + oldHeight;
    
    CGRect newInputFrame = self.textView.frame;
    newInputFrame.origin.y = Margin;
    newInputFrame.size.height = heightofTextView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.15 animations:^{
            [self setFrame:newSelfFrame];
            [self.textView setFrame:newInputFrame];
            [leftButton setFrame:CGRectMake(5, (ViewHeight - 40) - 4.5, ButtonWidth - 10, 40)];
        } completion:^(BOOL finished) {
        }];
        
    });
}

- (void)altEmojiKeyboardShowState{
    [self.keyboardView show:!self.keyboardView.isShowing];
    
    CGFloat y = self.keyboardView.isShowing ? (ScreenHeight - ViewHeight - 216) : (ScreenHeight - ViewHeight);
    
    CGRect frame = CGRectMake(0, y, ScreenWidth, ViewHeight);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.25 animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    });
}

- (CGFloat)contentofheight:(NSString *)content{
    return [self.textView systemLayoutSizeFittingSize:CGSizeMake(ScreenWidth - ButtonWidth * 2, 44) withHorizontalFittingPriority:(ScreenWidth - ButtonWidth * 2) verticalFittingPriority:UILayoutPriorityDefaultLow].height;
}

-(GGEmojiKeyboardView *)keyboardView{
    if (![_keyboardView isDescendantOfView:spv]) {
        _keyboardView = [[GGEmojiKeyboardView alloc] init];
        [_keyboardView showInView:spv];
    }
    return _keyboardView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
