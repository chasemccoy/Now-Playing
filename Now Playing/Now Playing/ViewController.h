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
#import "MBProgressHUD.h"
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
}

@property (strong, nonatomic) SLComposeViewController *tweetSheet;
@property (nonatomic, strong) DBImageColorPicker *colorPicker;
@property (nonatomic, strong) NSURL *songURL;
@property (strong, nonatomic) IBOutlet UIButton *tweetBox;
@property (strong, nonatomic) UIImageView *twitterLogo;

- (void)updateInfo;
- (void)getSongURL;
- (IBAction)tweetButton:(id)sender;
-(void)createTweetSheet;
- (void)handleSwipeLeft;
- (void)handleSwipeRight;
- (void)handleTap;
- (void)setBackgroundColor:(UIImage*)image;
- (void)showTutorial;

@end

