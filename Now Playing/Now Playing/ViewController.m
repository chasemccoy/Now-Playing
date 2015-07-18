//
//  ViewController.m
//  Now Playing
//
//  Created by Chase McCoy on 7/17/15.
//  Copyright © 2015 Chase McCoy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)updateInfo {
  songTitle.text = [nowPlaying getSongTitle];
  if (songTitle.text == nil) {
    songTitle.text = @"No Song Playing";
  }
  artist.text = [nowPlaying getArtist];
  
  CGSize artworkImageViewSize = albumArt.bounds.size;
  UIImage *artwork = [nowPlaying getAlbumArt:artworkImageViewSize];
  if (artwork != nil)
  {
    albumArt.image = artwork;
  }
  else
  {
    albumArt.image = [UIImage imageNamed:@"missingAlbum.png"];
  }
  
  albumArt.userInteractionEnabled = YES;
  
  //Swipe Left
  swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
  swipeLeftRecognizer = (UISwipeGestureRecognizer *)swipeLeftRecognizer;
  swipeLeftRecognizer.numberOfTouchesRequired = 1;
  swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  [albumArt addGestureRecognizer:swipeLeftRecognizer];
  
  //Swipe Right
  swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
  swipeRightRecognizer = (UISwipeGestureRecognizer *)swipeRightRecognizer;
  swipeRightRecognizer.numberOfTouchesRequired = 1;
  swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [albumArt addGestureRecognizer:swipeRightRecognizer];
  
  // Tap
  tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
  tapRecognizer.numberOfTapsRequired = 1;
  [albumArt addGestureRecognizer:tapRecognizer];
}

- (void)handleSwipeLeft {
  MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
  [musicPlayer skipToNextItem];
  [self updateInfo];
}

- (void)handleSwipeRight {
  MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
  [musicPlayer skipToPreviousItem];
  [self updateInfo];
}

- (void)handleTap {
  MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
  if (musicPlayer.playbackState == MPMusicPlaybackStatePaused || musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
    [musicPlayer play];
  }
  else if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
    [musicPlayer pause];
  }
  [self updateInfo];
}



// ****************************************
// Post in background: http://stackoverflow.com/questions/9423447/ios-5-twitter-framework-tweeting-without-user-input-and-confirmation-modal-vie
// ****************************************

- (IBAction)tweetButton:(id)sender {
  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    _tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSString *message = [NSString stringWithFormat:@"🎵: %@ by %@", [nowPlaying getSongTitle], [nowPlaying getArtist]];
    [_tweetSheet setInitialText:message];
    CGSize artworkImageViewSize = albumArt.bounds.size;
    [_tweetSheet addImage:[nowPlaying getAlbumArt:artworkImageViewSize]];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
    {
      
      [_tweetSheet dismissViewControllerAnimated:YES completion:nil];
      
      switch(result){
        case SLComposeViewControllerResultCancelled:
        default:
        {
          NSLog(@"Cancelled.....");
        }
          break;
        case SLComposeViewControllerResultDone:
        {
          NSLog(@"Posted....");
        }
          break;
      }};
    
    [_tweetSheet setCompletionHandler:completionHandler];
    
    [self presentViewController:_tweetSheet animated:YES completion:nil];
  }
  else {
    NSLog(@"Twitter not configured.");
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                         message:@"You need to setup a Twitter account in Settings."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:@"Settings", nil];
    [errorAlert show];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  [self setNeedsStatusBarAppearanceUpdate];
  
  nowPlaying = [[NowPlaying alloc] init];
  
  [self updateInfo];
  
  MPMusicPlayerController *musicPlayer = [MPMusicPlayerController systemMusicPlayer];
  
  [musicPlayer beginGeneratingPlaybackNotifications];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self selector:@selector(updateInfo) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                           object:musicPlayer];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateInfo];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    NSURL *url = [NSURL URLWithString:@"prefs:root=TWITTER"];
    [[UIApplication sharedApplication] openURL:url];
  }
}

@end
