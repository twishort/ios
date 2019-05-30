//
//  WebViewController.h
//  Twishort
//
//  Created by TMH on 20.04.15.
//  Copyright (c) 2015 TMH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSString *url;


@end
