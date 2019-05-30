//
//  TmhViewController.h
//  Twishort
//
//  Created by TMH on 22.09.13.
//  Copyright (c) 2013 TMH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCell.h"
#import "TmhLocation.h"

@interface ViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TmhLocationDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *avatarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *pasteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtons;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeftConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomPhotoConstraint;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIView *geoView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;


- (IBAction)avatarButton:(id)sender;
- (IBAction)sendButton:(id)sender;
- (IBAction)hideButton:(id)sender;
- (IBAction)pasteButton:(id)sender;
- (IBAction)addButton:(id)sender;
- (IBAction)photoButton:(id)sender;
- (IBAction)videoButton:(id)sender;
- (IBAction)photoSwipeGesture:(id)sender;
- (IBAction)viewBottomSwipeGesture:(id)sender;
- (IBAction)viewTopSwipeGesture:(id)sender;
- (IBAction)titleSwipeGesture:(id)sender;
- (IBAction)placeButton:(id)sender;



- (void)saveShare;

@end
