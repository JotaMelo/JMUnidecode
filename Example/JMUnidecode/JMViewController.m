//
//  JMViewController.m
//  JMUnidecode
//
//  Created by Jota Melo on 09/11/2017.
//  Copyright (c) 2017 Jota Melo. All rights reserved.
//

#import "JMViewController.h"
#import "JMUnidecode.h"

@interface JMViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation JMViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.resultLabel.text = [JMUnidecode unidecode:textField.text];
    [textField resignFirstResponder];
    return YES;
}

@end
