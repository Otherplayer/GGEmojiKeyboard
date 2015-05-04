//
//  ViewController.m
//  GGEmojiKeyboard
//
//  Created by __无邪_ on 15/5/3.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "ViewController.h"
#import "GGInputView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    GGInputView *inputView = [[GGInputView alloc] init];
    [inputView showInView:self.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenKeyboardNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
