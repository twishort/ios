//
//  WebViewController.m
//  Twishort
//
//  Created by TMH on 20.04.15.
//  Copyright (c) 2015 TMH. All rights reserved.
//

#import "WebViewController.h"
#import "UIView+HUD.h"

@implementation WebViewController

- (void)defineVariables
{
    
}

- (void)customizeInterface
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forward)];
    self.navigationItem.rightBarButtonItems = @[forward, back];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self defineVariables];
    [self customizeInterface];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

#pragma mark - Action

- (void)back
{
    [self.webView goBack];
}

- (void)forward
{
    [self.webView goForward];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view showWait];
}

- (void)webViewDidFinishLoad:(UIWebView *)view
{
    [self.view hideWait];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view hideWait];
}

@end
