//
//  ViewController.m
//  Twishort
//
//  Created by TMH on 19.04.15.
//  Copyright (c) 2015 TMH. All rights reserved.
//

#import "ViewController.h"
#import "UIView+HUD.h"
#import "TmhTwishort.h"
#import "WebViewController.h"
#import "Appirater.h"
#import "UIImage+Tmh.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TmhLocation.h"

const int kAssetsCount = 10;
const int kMaxImageCount = 4;
const int kImageWidthHeight = 960;
const float kVideoDurationMin = 0.5;
const float kVideoDurationMax = 30.1;
const int kVideoSizeMax = 15728640;

@implementation ViewController
{
    TmhTwishort *twishort;
    NSString *username;
    UIImagePickerController *imagePicker;
    UIPopoverController *popover;
    NSTimer *failTimer;
    UIBarButtonItem *imageButton;
    NSArray *assets;
    BOOL loadMoreAssets;
    NSDate *lastAssetDate;
    TmhLocation *location;
    NSArray *places;
    BOOL relogin;
    
    NSMutableArray *selectedAssets;
    NSArray *selectedImages;
    NSData *selectedVideo;
    NSDictionary *selectedPlace;
    CLLocationCoordinate2D selectedCoordinate;
    
    PHAsset *bgImageAsset;
}

- (void)defineVariables
{
    places = @[];
    assets = @[];
    selectedAssets = [NSMutableArray new];
    selectedImages = @[];
    selectedCoordinate = kCLLocationCoordinate2DInvalid;
    
    twishort = [[TmhTwishort alloc] initWithViewController:self];
    twishort.cancelText = NSLocalizedString(@"CANCEL", nil);
    [twishort setSelectAccountText:NSLocalizedString(@"SELECT ACCOUNT", nil)];
    location = [TmhLocation new];
    location.delegate = self;
    username = twishort.username;
    
    self.textView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"text"];
    if (self.textView.text.length > 0) {
        self.placeholderLabel.hidden = YES;
    }
    self.titleTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
    if (self.titleTextField.text.length > 0) {
        self.titlePlaceholderLabel.hidden = YES;
    }
    relogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"relogin"] boolValue];
    
    imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
    [imagePicker setModalPresentationStyle:UIModalPresentationFullScreen];
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(viewTopSwipeGesture:)];
    [pan setEdges:UIRectEdgeRight];
    [self.view addGestureRecognizer:pan];
}

- (void)customizeInterface
{
    [UIView setHUDTintColor:TmhColor(@"ColorTint")];
    TmhRoundView(self.pasteButton);
    TmhRoundView(self.hideButton);
    self.pasteButton.hidden =
    self.hideButton.hidden = YES;
    [self.pasteButton setBackgroundColor:TmhColor(@"ColorTint")];
    
    [self changeAvatarImage];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(0, 0, self.titleView.frame.size.width, self.titleView.frame.size.height);
    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleView insertSubview:blurEffectView belowSubview:self.titleTextField];
    [self.titleView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-0-[blurEffectView]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(blurEffectView)]];
    [self.titleView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|-0-[blurEffectView]-0-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(blurEffectView)]];
    
    
    UIBlurEffect *blurEffect2 = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView2 = [[UIVisualEffectView alloc] initWithEffect:blurEffect2];
    blurEffectView2.frame = CGRectMake(0, 0, self.geoView.frame.size.width, self.geoView.frame.size.height);
    blurEffectView2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.geoView insertSubview:blurEffectView2 belowSubview:self.placeLabel];
    [self.geoView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-0-[blurEffectView2]-0-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(blurEffectView2)]];
    [self.geoView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|-0-[blurEffectView2]-0-|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:NSDictionaryOfVariableBindings(blurEffectView2)]];
    
    UIBlurEffect *blurEffect3 = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView3 = [[UIVisualEffectView alloc] initWithEffect:blurEffect3];
    blurEffectView3.frame = CGRectMake(0, 0, self.photoView.frame.size.width, self.photoView.frame.size.height);
    blurEffectView3.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoView insertSubview:blurEffectView3 belowSubview:self.photosCollectionView];
    [self.photoView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:|-0-[blurEffectView3]-0-|"
                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(blurEffectView3)]];
    [self.photoView addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|-0-[blurEffectView3]-0-|"
                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                  metrics:nil
                                  views:NSDictionaryOfVariableBindings(blurEffectView3)]];
    
    UIImage *bgImage = [UIImage imageWithContentsOfFile:[self bgFilePath]];
    if (bgImage) {
        self.bgImageView.image = bgImage;
    }
    
    if (IPAD) {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(togglePhoto)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(toggleTitle)];
        UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"geo"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(toggleGeo)];
        UIView *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
        view.backgroundColor = [UIColor clearColor];
        UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithCustomView:view];
        
        self.navigationItem.rightBarButtonItems = @[self.sendButton, separator, item3,item2,item1];
        
        
        self.textView.font = [self.textView.font fontWithSize:32];
        self.placeholderLabel.font = [self.placeholderLabel.font fontWithSize:24];
        self.titleTextField.font = [self.titleTextField.font fontWithSize:24];
        self.titlePlaceholderLabel.font = [self.placeholderLabel.font fontWithSize:24];
        self.placeLabel.font = [self.placeLabel.font fontWithSize:20];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self defineVariables];
    [self customizeInterface];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self updateStatus];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self.textView resignFirstResponder];
    [self changeAvatarImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.titleTextField.text.length > 0) {
        [self showTitle];
    }
}

#pragma mark - Button

- (IBAction)sendButton:(id)sender
{
    [self send];
}

- (IBAction)pasteButton:(id)sender
{
    [self paste];
}

- (IBAction)addButton:(id)sender
{
    [self add];
}

- (IBAction)photoButton:(id)sender
{
    [self takePhotoAndVideo];
}

- (IBAction)videoButton:(id)sender
{
    [self takePhotoAndVideo];
}

- (IBAction)hideButton:(id)sender
{
    [self hide];
}

- (IBAction)avatarButton:(id)sender
{
    [self.view endEditing:YES];
    [self avatar];
}

- (IBAction)photoSwipeGesture:(id)sender
{
    [self hidePhoto];
}

- (IBAction)viewTopSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    if (point.y < self.view.frame.size.height / 2) {
        if (self.titleView.hidden) {
            [self showTitle];
        }
    } else {
        if (self.geoView.hidden) {
            [self showGeo];
        }
    }
}

- (IBAction)viewBottomSwipeGesture:(id)sender
{
    if (self.photoView.hidden) {
        [self showPhoto];
    }
}

- (IBAction)titleSwipeGesture:(id)sender
{
    [self hideTitle];
}

- (IBAction)placeButton:(id)sender
{
    if (places.count) {
        [self showPlaceSelection];
    } else {
        [self location];
    }
}


#pragma mark - Helper

- (NSString *)bgFilePath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"bg.jpg"];
}

#pragma mark - Action

- (void)saveShare
{
    if (self.textView.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.textView.text forKey:@"text"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"text"];
    }
    if (self.titleTextField.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.titleTextField.text forKey:@"title"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"title"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)add
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"OPEN LIBRARY", nil),
                                  NSLocalizedString(@"ADD TITLE", nil),
                                  NSLocalizedString(@"ADD GEO", nil), nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    actionSheet.tag = 1;
    [actionSheet showFromBarButtonItem:self.addButton animated:YES];
}

- (void)addPhoto
{
    if (self.photoView.hidden) {
        [self showPhoto];
    } else {
        [self hidePhoto];
    }
}

- (void)addTitle
{
    if (self.titleView.hidden) {
        [self showTitle];
    } else {
        [self hideTitle];
    }
}

- (void)addGeo
{
    if (self.geoView.hidden) {
        [self showGeo];
    } else {
        [self hideGeo];
    }
}

- (void)toggleTitle
{
    if (self.titleView.hidden) {
        [self showTitle];
    } else {
        [self hideTitle];
    }
}

- (void)showTitle
{
    [self.view endEditing:YES];

    self.titleView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.titleTopConstraint.constant = 0;
                         [self.titleView.layer layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self.titleTextField becomeFirstResponder];
                     }];
}

- (void)showTitleTemporarily
{
    self.titleView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.titleTopConstraint.constant = 0;
                         [self.titleView.layer layoutIfNeeded];
                     }];
}

- (void)hideTitle
{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.titleTopConstraint.constant = -self.titleView.frame.size.height;
                         [self.titleView.layer layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.titleView.hidden = YES;
                         self.titleTextField.text = nil;
                     }];
}

- (void)hideTitleTemporarily
{
    [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.titleTopConstraint.constant = -self.titleView.frame.size.height;
                         [self.titleView.layer layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.titleView.hidden = YES;
                     }];
}

- (void)toggleGeo
{
    if (self.geoView.hidden) {
        [self showGeo];
    } else {
        if (IPAD
            && places.count) {
            [self showPlaceSelection];
        } else {
            [self hideGeo];
        }
    }
}

- (void)showGeo
{
    [self.view endEditing:YES];

    self.geoView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.geoHeightConstraint.constant = self.placeHeightConstraint.constant;
                         [self.geoView.layer layoutIfNeeded];
                     }];
    self.placeLabel.text = NSLocalizedString(@"LOCATION SEARCHING", nil);

    [self location];
}

- (void)hideGeo
{
    selectedCoordinate = kCLLocationCoordinate2DInvalid;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.geoHeightConstraint.constant = 0;
                         [self.geoView.layer layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.geoView.hidden = YES;
                     }];
}

- (void)togglePhoto
{
    if (self.photoView.hidden) {
        [self showPhoto];
    } else {
        [self hidePhoto];
    }
}

- (void)showPhoto
{
    [self.view endEditing:YES];
    
    [self updateLibraryImages];
    
    self.photoView.hidden = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomPhotoConstraint.constant = 0;
                         [self.view.layer layoutIfNeeded];
                     }];
}

- (void)hidePhoto
{
    [selectedAssets removeAllObjects];

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomPhotoConstraint.constant = -self.photoView.frame.size.height;
                         [self.view.layer layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.photoView.hidden = YES;
                     }];
}

- (void)avatar
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"OPEN TWITTER", nil),
                                  NSLocalizedString(@"OPEN TWISHORT", nil),
                                  NSLocalizedString(@"OPEN SUPPORT", nil), nil];
    if ((twishort.isAuthorized
         && username)) {
        [actionSheet addButtonWithTitle:[relogin?@"✔︎ ":@"" stringByAppendingString:NSLocalizedString(@"ASK ACCOUNT", nil)]];
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"LOGOUT", nil)];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    actionSheet.tag = 0;
    if (username) {
        actionSheet.title = [NSString stringWithFormat:@"@%@", username];
    }
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
}

- (void)paste
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    id<UITextInput> textInput = [self.titleTextField isFirstResponder] ? self.titleTextField : self.textView;
    
    if ([textInput isKindOfClass:UITextView.class] &&
        (textInput.selectedTextRange == nil
        || textInput.selectedTextRange.empty)) {
        [((UITextView *)textInput) setSelectedRange:NSMakeRange(((UITextView *)textInput).selectedRange.location, 0)];
    }
    
    NSString *pasteText = [gpBoard string];
    if (pasteText != nil) {
        [textInput insertText:[gpBoard string]];
    }
}

- (void)hide
{
    [self.view endEditing:YES];
}

- (void)clear
{
    self.textView.text = @"";
    self.placeholderLabel.hidden = NO;
    self.titleTextField.text = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"text"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    selectedVideo = nil;
    selectedImages = @[];
    selectedPlace = nil;
    selectedCoordinate = kCLLocationCoordinate2DInvalid;
    [selectedAssets removeAllObjects];
    [self.photosCollectionView reloadData];

    [self hidePhoto];
    [self hideTitle];
    [self hideGeo];
}

- (void)openUrl:(NSString *)url
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"Web"];
    vc.url = url;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)support
{
    [self openUrl:TmhSettings(@"UrlSupport")];
}

- (void)logout
{
    [twishort logout];
    [self.avatarButton setImage:[UIImage imageNamed:@"avatar"]];
    [self updateStatus];
}

- (void)changeAvatarImage
{
    UIImage *image = twishort.avatar;
    if (image) {
        float height = self.navigationController.navigationBar.frame.size.height;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake(0, 0, height, height);
        button.layer.cornerRadius = height / 2.0;
        button.layer.masksToBounds = YES;
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(avatarButton:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"avatar"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(avatarButton:)];
    }
}

- (void)updateLibraryImages
{
    [self loadAssetsWithMore:NO];
}

- (void)loadMoreAssets
{
    [self loadAssetsWithMore:YES];
}

- (void)loadAssetsWithMore:(BOOL)isMore
{
    if (!isMore) {
        assets = @[];
    }
    loadMoreAssets = isMore;
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"(mediaType = %d OR mediaType = %d) AND creationDate < %@", PHAssetMediaTypeImage, PHAssetMediaTypeVideo,
                              isMore ? lastAssetDate : [NSDate distantFuture]];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHFetchResult *result = [PHAsset fetchAssetsWithOptions:fetchOptions];

        if (result.count == 0) {
            if (!isMore) {
                loadMoreAssets = YES; // prevent load more assets
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.photosCollectionView reloadData];
                    if (assets.count == 0
                        && [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
                        [self hidePhoto];
                        [self showPhotoPrivacy];
                    }
                });
            }
            return;
        }
        
        int i = 0;
        for (PHAsset *asset in result) {
            if (i == kAssetsCount) {
                break;
            }
            assets = [assets arrayByAddingObject:asset];
            lastAssetDate = asset.creationDate;
            i++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isMore) {
                [self.photosCollectionView setContentOffset:CGPointMake(0, 0) animated:NO]; // scroll to beginning
            }
            [self.photosCollectionView reloadData];
        });
        loadMoreAssets = NO; // clear load more state
    });
}

- (void)location
{
    [location search];
}

- (void)selectPlace
{
    [twishort placesWithCoordinate:selectedCoordinate success:^(NSArray *list) {
        
        places = [list subarrayWithRange:NSMakeRange(0, MIN(10, list.count))];
        [self showPlaceSelection];
        
    } error:^(NSError *error) {
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR TITLE", nil)
                                    message:error.localizedDescription ? error.localizedDescription : NSLocalizedString(@"ERROR GEO PLACES", nil)
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

- (void)showPlaceSelection
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    for (NSDictionary *place in places) {
        [as addButtonWithTitle:place[@"full_name"]];
    }
    [as addButtonWithTitle:NSLocalizedString(@"HIDE", nil)];
    as.destructiveButtonIndex = places.count;
    as.cancelButtonIndex = [as addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    as.tag = 2;
    if (IPAD) {
        [as showFromBarButtonItem:self.navigationItem.rightBarButtonItems[2] animated:YES];
    } else {
        [as showFromRect:self.geoView.frame inView:self.view animated:YES];
    }
}

- (void)showSetBackground
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CHOOSE BACKGROUND", nil)
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                       otherButtonTitles:nil];
    av.tag = 1;
    if (self.bgImageView.image) {
        [av addButtonWithTitle:NSLocalizedString(@"REMOVE", nil)];
    }
    [av addButtonWithTitle:NSLocalizedString(@"SET", nil)];
    
    [av show];
}

- (void)longTapPhoto:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        PHAsset *asset = assets[gesture.view.superview.superview.tag];
        if (asset.mediaType == PHAssetMediaTypeImage) {
            bgImageAsset = asset;
            [self showSetBackground];
        }
    }
}

- (void)showPhotoPrivacy
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PRIVACY", nil)
                                                 message:NSLocalizedString(@"PRIVACY PHOTO", nil)
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                       otherButtonTitles:nil];
    av.tag = 2;
    [av show];
}

- (void)showVideoLimit
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWITTER LIMITS", nil)
                                message:NSLocalizedString(@"TWITTER LIMITS VIDEO", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}


#pragma mark - Twitter

- (void)updateStatus
{
    if ([twishort isAuthorized]) {
        
        if (! username
            || (!IOS11 && twishort.account && ![twishort.account.username isEqualToString:username])) {
            [twishort userInfo:^(NSDictionary *info){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    username = [info objectForKey:kTmhSocialTwitterParamUsername];
                    twishort.username = username;
                    NSString *avatarUrl = info[kTmhSocialTwitterParamAvatar];
                    
                    if (avatarUrl) {
                        TmhConnection *con = [TmhConnection new];
                        con.type = TmhConnectionTypeData;
                        [con GET:avatarUrl
                       onSuccess:^(id data) {
                           UIImage *image = [UIImage imageWithData:data];
                           twishort.avatar = image;
                           [self changeAvatarImage];
                       } onError:^(int statusCode, id data) {
                           twishort.avatar = nil;
                           [self changeAvatarImage];
                       }];
                    } else {
                        twishort.avatar = nil;
                        [self changeAvatarImage];
                    }
                });
            } onError:nil];
        }
    } else {
        twishort.avatar = nil;
        username = nil;
        [self changeAvatarImage];
    }
}

#pragma mark - Send

- (void)prepareMedia
{
    if (((PHAsset *)selectedAssets[0]).mediaType == PHAssetMediaTypeVideo) {
        // video
        [[PHImageManager defaultManager] requestAVAssetForVideo:(PHAsset *)selectedAssets[0]
                                                        options:nil
                                                  resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                                      
                                                      NSDictionary *d = [((AVURLAsset *)asset).URL resourceValuesForKeys:@[NSURLFileSizeKey] error:nil];
                                                      int size = [d[NSURLFileSizeKey] intValue];
                                                      if (size > kVideoSizeMax) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.view hideWait];
                                                              [self showVideoLimit];
                                                          });
                                                          return;
                                                      }
                                                      
                                                      selectedVideo = [NSData dataWithContentsOfURL:((AVURLAsset *)asset).URL];
                                                      [self send];
                                                  }];
    } else {
        // images
        PHAsset *asset = selectedAssets[selectedImages.count];
        /*
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:nil
                                                    resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                        selectedImages = [selectedImages arrayByAddingObject:imageData?imageData:[NSData new]]; // empty image on fail
                                                        if (selectedAssets.count == selectedImages.count) {
                                                            [self send];
                                                        } else {
                                                            [self prepareMedia];
                                                        }
                                                    }];*/
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(kImageWidthHeight, kImageWidthHeight)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result.size.width >= 200) { // if thumbnail ignore
                                                        NSData *imageData = UIImageJPEGRepresentation(result, 0.7);
                                                        selectedImages = [selectedImages arrayByAddingObject:imageData?imageData:[NSData new]]; // empty image on fail
                                                        if (selectedAssets.count == selectedImages.count) {
                                                            [self send];
                                                        } else {
                                                            [self prepareMedia];
                                                        }
                                                    }
                                                }];
    }
}

- (void)send
{
    NSString *tweet = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tweet.length == 0) {
        return;
    }

    if (!self.view.isWaiting) {
        [self.view showWait];
    }
    
    [self.view endEditing:YES];

    if (selectedAssets.count &&
        !(selectedVideo || selectedImages.count)) {
        [self prepareMedia];
        return;
    }

    [self startFailTimeout];

    if (CLLocationCoordinate2DIsValid(selectedCoordinate)) {
        //selectedCoordinate = CLLocationCoordinate2DMake(((int)(selectedCoordinate.latitude * 10)) / 10.0, ((int)(selectedCoordinate.longitude * 10)) / 10.0);
        selectedCoordinate = CLLocationCoordinate2DMake(selectedCoordinate.latitude, selectedCoordinate.longitude);
    }
    
    twishort.reselectAccount = relogin;
    twishort.isHud = YES;
    self.parentViewController.view.userInteractionEnabled = NO;

    [twishort share:tweet
             images:selectedImages
              video:selectedVideo
              title:title
         coordinate:selectedCoordinate
              place:selectedPlace[@"full_name"]
            placeId:selectedPlace[@"id"]
          onSuccess:^{
              dispatch_async(dispatch_get_main_queue(), ^{
                  [Appirater userDidSignificantEvent:YES];
                  twishort.reselectAccount = NO;
                  twishort.isHud = NO;
                  [self stopFailTimeout];
                  [self clear];
                  [self.view hideWait];
                  [self updateStatus];
                  self.parentViewController.view.userInteractionEnabled = YES;
                  
                  UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"APP TITLE", nil)
                                                               message:NSLocalizedString(@"POSTED", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                     otherButtonTitles:NSLocalizedString(@"SHOW", nil), nil];
                  av.tag = 3;
                  [av show];
              });
          } onError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  twishort.reselectAccount = NO;
                  twishort.isHud = NO;
                  
                  // Remove cached images/video
                  selectedVideo = nil;
                  selectedImages = @[];
                  
                  [self.view hideWait];
                  [self updateStatus];
                  self.parentViewController.view.userInteractionEnabled = YES;
                  
                  [self stopFailTimeout];
                  if (! error) {
                      return;
                  }
                  NSString *errorText;
                  switch (error.code) {
                      case kTmhSocialErrorAccount:
                          errorText = @"ERROR NO ACCOUNT";
                          break;
                      case kTmhSocialTwitterErrorDuplicate:
                          errorText = @"ERROR SHARE DUPLICATE";
                          break;
                      case kTmhSocialTwitterErrorRateLimit:
                          errorText = @"ERROR RATE LIMIT";
                          break;
                      case kTmhTwishortErrorAuth:
                          errorText = @"ERROR TWISHORT AUTH";
                          break;
                      case kTmhTwishortErrorShare:
                          errorText = @"ERROR TWISHORT SHARE";
                          break;
                      case kTmhTwishortErrorSignature:
                          errorText = @"ERROR TWISHORT SIGN";
                          break;
                      default:
                          errorText = error.localizedDescription;
                  }
                  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR TITLE", nil)
                                              message:NSLocalizedString(errorText, nil)
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil] show];
              });
          }];
}

#pragma mark - Fail

- (void)startFailTimeout
{
    failTimer = [NSTimer scheduledTimerWithTimeInterval:TmhSettingsInt(@"FailInterval")
                                                 target:self
                                               selector:@selector(failTimeout)
                                               userInfo:nil
                                                repeats:NO];
}

- (void)failTimeout
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR TITLE", nil)
                                message:NSLocalizedString(@"ERROR LONG TIME", nil)
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)stopFailTimeout
{
    [failTimer invalidate];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!IPAD
        && !self.titleView.hidden) {
        [self hideTitleTemporarily];
    }
    self.placeholderLabel.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }
    if (self.titleTextField.text.length) {
        [self showTitleTemporarily];
    }
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.titlePlaceholderLabel.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField.text.length == 0) {
        self.titlePlaceholderLabel.hidden = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return NO;
}

#pragma mark - Keyboard

- (void)keyboardShow:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];

    self.pasteButton.alpha =
    self.hideButton.alpha = 0;
    self.pasteButton.hidden =
    self.hideButton.hidden = IPAD;
    self.bottomButtons.constant = 0;

    float height = UIInterfaceOrientationIsPortrait(interfaceOrientation)||!IOS7 ? kbSize.height : kbSize.width;
    
    [UIView animateWithDuration:duration + 0.2
                          delay:0
                        options:options
                     animations:^{
                         self.bottom.constant = height + (IPAD?0:(self.pasteButton.frame.size.height+10))
                            - (self.photoView.hidden?0:self.photoView.frame.size.height)
                            - (self.geoView.hidden?0:self.placeHeightConstraint.constant);
                         self.bottomButtons.constant = height + 5;
                         self.pasteButton.alpha =
                         self.hideButton.alpha = 1;
                         [self.view.layer layoutIfNeeded];
                     } completion:nil];
}

- (void)keyboardHide:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:duration - 0.1
                          delay:0
                        options:options
                     animations:^{
                         self.bottom.constant =
                         self.bottomButtons.constant = 0;
                         self.pasteButton.alpha =
                         self.hideButton.alpha = 0;
                         self.pasteButton.hidden =
                         self.hideButton.hidden = YES;
                         [self.view.layer layoutIfNeeded];
                     } completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return assets.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    PHAsset *asset = assets[indexPath.row];
    [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)asset
                                               targetSize:CGSizeMake(110, 110)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                cell.thumbImageView.image = result;
                                            }];
    cell.selectedView.hidden = ![selectedAssets containsObject:asset];
    cell.tag = indexPath.row;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoView.hidden = NO;
        cell.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)floor(asset.duration / 60.0), (int)fmod(asset.duration, 60)];
    } else {
        cell.videoView.hidden = YES;
    }
    
    // Add gesture recognizer
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapPhoto:)];
    [longPressGesture setMinimumPressDuration:1.0];
    UIView *view = [cell viewWithTag:-1];
    if (!view.gestureRecognizers.count) {
        [view addGestureRecognizer:longPressGesture];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[self.photosCollectionView cellForItemAtIndexPath:indexPath];
    PHAsset *asset = assets[indexPath.row];
    
    if (asset.mediaType == PHAssetMediaTypeVideo
        && (asset.duration < kVideoDurationMin || asset.duration > kVideoDurationMax)) {
        [self showVideoLimit];
        return;
    }
    
    if ([selectedAssets containsObject:asset]) {
        [selectedAssets removeObject:asset];
        cell.selectedView.hidden = YES;
    } else {
        if (selectedAssets.count) {
            PHAsset *firstSelectedAsset = selectedAssets[0];
            if ((firstSelectedAsset.mediaType == PHAssetMediaTypeVideo
                && asset.mediaType == PHAssetMediaTypeImage)
                || (firstSelectedAsset.mediaType == PHAssetMediaTypeImage
                    && asset.mediaType == PHAssetMediaTypeVideo)
                || (firstSelectedAsset.mediaType == PHAssetMediaTypeVideo
                    && asset.mediaType == PHAssetMediaTypeVideo)) {
                [selectedAssets removeAllObjects];
                [self.photosCollectionView reloadData];
            } else if (selectedAssets.count == kMaxImageCount) {
                [selectedAssets removeObjectAtIndex:0];
                [self.photosCollectionView reloadData];
            }
        }
        [selectedAssets addObject:asset];
        cell.selectedView.hidden = NO;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.photosCollectionView) {
        // UITableView only moves in one direction, y axis
        CGFloat currentOffset = scrollView.contentOffset.x;
        CGFloat maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width;
        
        if (maximumOffset - currentOffset <= (self.view.frame.size.width / 4)
            && !loadMoreAssets) {
            [self loadMoreAssets];
        }
    }
}

#pragma mark - Take image

- (void)takePhotoAndVideo
{
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePicker.videoMaximumDuration = kVideoDurationMax;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)hidePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self.view hideWait];
}

- (void)didVideoSaving:(NSString *)path error:(NSError *)error contextInfo:(void *)contextInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            DLog(@"Finished saving video with error: %@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR SAVE VIDEO", nil)
                                       message:error.localizedDescription
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] show];
        } else {
            [self updateLibraryImages];
        }
        [self hidePicker];
    });
}

- (void)didPhotoSaving:(UIImage *)image error:(NSError *)error contextInfo:(void *)contextInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            DLog(@"Finished saving photo with error: %@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR SAVE PHOTO", nil)
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        } else {
            [self updateLibraryImages];
        }
        [self hidePicker];
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.view showWait];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        NSString *tempFilePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        if (tempFilePath) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, @selector(didVideoSaving:error:contextInfo:), (__bridge void * _Nullable)(tempFilePath));
            } else {
                NSError *e = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR SAVE VIDEO INCOMPATIBLE", nil)}];
                [self didVideoSaving:tempFilePath error:e contextInfo:nil];
            }
        } else {
            UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerEditedImage];
            if (image == nil) {
                image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
            }
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(didPhotoSaving:error:contextInfo:), nil);
        }
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self hidePicker];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 0:
            switch (buttonIndex) {
                case 0:
                    [self openUrl:username?[NSString stringWithFormat:TmhSettings(@"UrlTwitterUsername"), username]:TmhSettings(@"UrlTwitter")];
                    break;
                case 1:
                    [self openUrl:username?[NSString stringWithFormat:TmhSettings(@"UrlTwishortUsername"), username]:TmhSettings(@"UrlTwishort")];
                    break;
                case 2:
                    [self support];
                    break;
                case 3:
                    if (username) {
                        relogin = !relogin;
                        [[NSUserDefaults standardUserDefaults] setObject:@(relogin) forKey:@"relogin"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    break;
                case 4:
                    if (username) {
                        [self logout];
                    }
                    break;
            }
            break;
        case 1:
            switch (buttonIndex) {
                case 0:
                    [self addPhoto];
                    break;
                case 1:
                    [self addTitle];
                    break;
                case 2:
                    [self addGeo];
                    break;
            }
            break;
        case 2:
            if (buttonIndex < places.count) {
                selectedPlace = places[buttonIndex];
                self.placeLabel.text = selectedPlace[IPAD?@"full_name":@"name"];
            } else  if (buttonIndex == places.count) {
                [self hideGeo];
            }
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            if (self.bgImageView.image
                && buttonIndex == 1) {
                self.bgImageView.image = nil;
                [[NSFileManager defaultManager] removeItemAtPath:[self bgFilePath] error:nil];
            } else if (buttonIndex != 0) {
                [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)bgImageAsset
                                                           targetSize:PHImageManagerMaximumSize
                                                          contentMode:PHImageContentModeDefault
                                                              options:nil
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            self.bgImageView.image = result;
                                                            // Save image.
                                                            [UIImageJPEGRepresentation(result, 0.8) writeToFile:[self bgFilePath] atomically:YES];
                                                        }];
            }
            bgImageAsset = nil;
            break;
        case 2:
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                [self showPhoto];
            }
            break;
        case 3:
            if (buttonIndex == 1) {
                NSString *url = [NSString stringWithFormat:kTmhSocialTwitterUrlUserProfile, username, twishort.lastTweetId];
                [self openUrl:url];
            }
            break;
    }
}

#pragma mark - TmhLocationDelegate

- (void)updateLocation:(CLLocation *)loc
{
    self.placeLabel.text = [NSString stringWithFormat:@"%0.3f : %0.3f", loc.coordinate.latitude, loc.coordinate.longitude];
    selectedCoordinate = loc.coordinate;
    places = nil;
    
    [self selectPlace];
}

- (void)failLocation:(NSError *)error
{
    NSString *errorText;
    places = nil;

    switch (error.code) {
        case TmhLocationErrorStatusUnauthorize:
            errorText = NSLocalizedString(@"ERROR GEO UNAUTHORIZED", nil);
            break;
        case TmhLocationErrorStatusTimer:
            errorText = NSLocalizedString(@"ERROR GEO FAIL", nil);
            break;
        default:
            errorText = error.localizedDescription.length ? error.localizedDescription : NSLocalizedString(@"ERROR GEO FAIL", nil);
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR TITLE", nil)
                                message:errorText
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    [self hideGeo];
}


@end
