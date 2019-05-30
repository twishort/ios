//
//  PhotoCell.h
//  Twishort
//
//  Created by TMH on 27.11.16.
//  Copyright © 2016 TMH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *selectedView;

- (IBAction)checkButton:(id)sender;

@end
