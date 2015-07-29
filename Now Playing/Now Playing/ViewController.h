//
//  ViewController.h
//  Now Playing
//
//  Created by Chase McCoy on 7/17/15.
//  Copyright © 2015 Chase McCoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingDelegate.h"
#import "DBImageColorPicker.h"
#import "MGInstagram.h"
@import MediaPlayer;
@import Social;

@interface ViewController : UIViewController {
  NowPlaying *nowPlaying;
  __weak IBOutlet UILabel *songTitle;
  __weak IBOutlet UILabel *artist;
  __weak IBOutlet UIImageView *albumArt;
  UISwipeGestureRecognizer *swipeLeftRecognizer;
  UISwipeGestureRecognizer *swipeRightRecognizer;
  UITapGestureRecognizer *tapRecognizer;
  __weak IBOutlet UIButton *tweetButton;
  __weak IBOutlet UIButton *facebookButton;
}

@property (strong, nonatomic) SLComposeViewController *tweetSheet;
@property (strong, nonatomic) SLComposeViewController *postSheet;
@property (nonatomic, strong) DBImageColorPicker *colorPicker;

- (void)updateInfo;
- (IBAction)tweetButton:(id)sender;
- (void)handleSwipeLeft;
- (void)handleSwipeRight;
- (void)handleTap;
- (void)setBackgroundColor:(UIImage*)image;
- (void)showTutorial;

@end

