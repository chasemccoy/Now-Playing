//
//  ViewController.h
//  Now Playing
//
//  Created by Chase McCoy on 7/17/15.
//  Copyright © 2015 Chase McCoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingDelegate.h"
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
}

@property (strong, nonatomic) SLComposeViewController *tweetSheet;

- (void)updateInfo;
- (IBAction)tweetButton:(id)sender;
- (void)handleSwipeLeft;
- (void)handleSwipeRight;
- (void)handleTap;

@end

