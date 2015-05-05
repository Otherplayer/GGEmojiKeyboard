//
//  GGEmojiKeyboardView.m
//  GGEmojiKeyboard
//
//  Created by __无邪_ on 15/5/4.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGEmojiKeyboardView.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

const CGFloat kKeyboardHeight = 216.f;

@implementation GGEmojiKeyboardView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kKeyboardHeight)];
        [self setBackgroundColor:[UIColor redColor]];
        [self setIsShowing:NO];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kKeyboardHeight)];
        [self setBackgroundColor:[UIColor colorWithRed:0.820 green:0.599 blue:0.902 alpha:1.000]];
        [self setIsShowing:NO];
    }
    return self;
}

-(void)showInView:(UIView *)superView{
    [superView addSubview:self];
}

- (void)show:(BOOL)show{
    CGRect newFrame;
    if (show) {
        newFrame = CGRectMake(0, kScreenHeight - kKeyboardHeight, kScreenWidth, kKeyboardHeight);
        [self setIsShowing:YES];
    }
    else{
        newFrame = CGRectMake(0, kScreenHeight, kScreenWidth, kKeyboardHeight);
        [self setIsShowing:NO];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setFrame:newFrame];
    }];
}


@end
