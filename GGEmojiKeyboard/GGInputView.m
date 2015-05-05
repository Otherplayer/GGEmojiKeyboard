//
//  GGInputView.m
//  GGEmojiKeyboard
//
//  Created by __无邪_ on 15/5/3.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGInputView.h"
#import "GGEmojiKeyboardView.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

const  CGFloat  kButtonWidth = 64.0f;
const  CGFloat  kMargin = 6.25f;
const  CGFloat  kInputViewHeight = 36.5f;//36.5
static CGFloat  kViewHeight = kInputViewHeight + kMargin * 2;


NSString *const kHiddenKeyboardNotification = @"kHiddenKeyboardNotification";

@interface GGInputView ()<UITextViewDelegate>
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, unsafe_unretained) BOOL systemKeyboardisShowing;

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
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, kScreenWidth, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:line];
        
        self.systemKeyboardisShowing = NO;
        
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
    [superView bringSubviewToFront:self];
    spv = superView;
    [self registerNotification];
    [self setFrame:CGRectMake(0, superView.bounds.size.height - kViewHeight, kScreenWidth, kViewHeight)];
    [self setupInputView];
    [self setupFunctionView];
}

#pragma mark -
#pragma mark - Setup
- (void)setupInputView{
    
    UIFont *font = [UIFont systemFontOfSize:17];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(kButtonWidth, kMargin, kScreenWidth - kButtonWidth * 2, kInputViewHeight) textContainer:nil];
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
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, (kViewHeight - 40) / 2, kButtonWidth - 10, 40)];
    [self addSubview:leftButton];
    [leftButton setBackgroundColor:[UIColor grayColor]];
    
    [leftButton addTarget:self
                   action:@selector(leftButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Action
- (void)leftButtonAction:(id)sender{

    if (self.keyboardView.isShowing) {
        [self.textView becomeFirstResponder];
    }
    else{
        [self altEmojiKeyboardShowState:YES];
        
        if (self.systemKeyboardisShowing) {
            [self.textView resignFirstResponder];
        }
    }
}

#pragma mark -
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    [self uipdateInputViewUI:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

#pragma mark - Notification

- (void)keyboardWillShowNotification:(NSNotification *)noti{
    NSTimeInterval animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect currentRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (currentRect.size.height < 216) {
        return;//切换键盘时会出现本通知执行多次的现象，I don't know why!!
    }
    self.systemKeyboardisShowing = YES;
    
    CGRect frame = CGRectMake(0, kScreenHeight - kViewHeight - currentRect.size.height, kScreenWidth, kViewHeight);
    [self updateUI:frame animationDuration:animationDuration];

    if (self.keyboardView.isShowing) {
        [self.keyboardView show:NO];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)noti{

    NSTimeInterval animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = CGRectMake(0, kScreenHeight - kViewHeight, kScreenWidth, kViewHeight);
    self.systemKeyboardisShowing = NO;
    if (!self.keyboardView.isShowing) {
        [self updateUI:frame animationDuration:animationDuration];
    }
}

- (void)hideEmojiKeyboardNotification:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.keyboardView.isShowing) {
            [self altEmojiKeyboardShowState:NO];
        }
    });
}

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideEmojiKeyboardNotification:) name:kHiddenKeyboardNotification object:nil];
}


- (void)updateUI:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:animationDuration animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    });
}

#pragma mark - Private

- (void)uipdateInputViewUI:(UITextView *)textView{
    CGFloat heightofTextView = [self contentofheight:textView.text];
    CGRect newSelfFrame = self.frame;
    CGFloat oldHeight = newSelfFrame.size.height;
    CGFloat newHeight = heightofTextView + kMargin * 2;
    
    kViewHeight = newHeight;
    
    newSelfFrame.size.height = newHeight;
    newSelfFrame.origin.y = newSelfFrame.origin.y - newHeight + oldHeight;
    
    CGRect newInputFrame = self.textView.frame;
    newInputFrame.origin.y = kMargin;
    newInputFrame.size.height = heightofTextView;
    
    [UIView animateWithDuration:0.15 animations:^{
        [self setFrame:newSelfFrame];
        [self.textView setFrame:newInputFrame];
        [leftButton setFrame:CGRectMake(5, (kViewHeight - 40) - 4.5, kButtonWidth - 10, 40)];
    } completion:^(BOOL finished) {
    }];
}

- (void)altEmojiKeyboardShowState:(BOOL)show{
    [self.keyboardView show:show];
    
    CGFloat y = show ? (kScreenHeight - kViewHeight - kKeyboardHeight) : (kScreenHeight - kViewHeight);
    
    CGRect frame = CGRectMake(0, y, kScreenWidth, kViewHeight);
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:frame];
    } completion:^(BOOL finished) {
    }];
}

- (CGFloat)contentofheight:(NSString *)content{
    return [self.textView systemLayoutSizeFittingSize:CGSizeMake(kScreenWidth - kButtonWidth * 2, 44) withHorizontalFittingPriority:(kScreenWidth - kButtonWidth * 2) verticalFittingPriority:UILayoutPriorityDefaultLow].height;
}

-(GGEmojiKeyboardView *)keyboardView{
    if (![_keyboardView isDescendantOfView:spv]) {
        _keyboardView = [[GGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 0)];
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
