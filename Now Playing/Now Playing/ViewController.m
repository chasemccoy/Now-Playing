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
    songTitle.text = @"Play a song!";
    tweetButton.enabled = NO;
    tweetButton.hidden = YES;
  }
  else {
    tweetButton.enabled = YES;
    tweetButton.hidden = NO;
  }
  
  artist.text = [nowPlaying getArtist];
  artist.text = [artist.text uppercaseString];
  
  CGSize artworkImageViewSize = albumArt.bounds.size;
  UIImage *artwork = [nowPlaying getAlbumArt:artworkImageViewSize];
  [self setBackgroundColor:artwork];
  if (artwork != nil)
  {
    albumArt.image = artwork;
    self.view.backgroundColor = _colorPicker.backgroundColor;
    songTitle.textColor = _colorPicker.primaryTextColor;
    artist.textColor = _colorPicker.secondaryTextColor;
  }
  else
  {
    //albumArt.image = [UIImage imageNamed:@"missingAlbum.png"];
    albumArt.image = nil;
    songTitle.textColor = [UIColor whiteColor];
    artist.textColor = [UIColor whiteColor];
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
  NSLog(@"starting...");
  [self displayTransitionImage:1];
  NSLog(@"done!");
  
  [self.musicPlayer skipToNextItem];
  [self updateInfo];
}

- (void)handleSwipeRight {
  NSLog(@"starting...");
  [self displayTransitionImage:2];
  NSLog(@"done!");
  
  [self.musicPlayer skipToPreviousItem];
  [self updateInfo];
}

- (void)handleTap {
  if (self.musicPlayer.playbackState == MPMusicPlaybackStatePaused
      || self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
    NSLog(@"starting...");
    [self displayTransitionImage:3];
    NSLog(@"done!");
    
    [self.musicPlayer play];
  }
  else if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
    NSLog(@"starting...");
    [self displayTransitionImage:4];
    NSLog(@"done!");
    
    [self.musicPlayer pause];
  }
  [self updateInfo];
}





- (void)displayTransitionImage:(NSInteger)whichImage {
  UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, albumArt.frame.size.width, albumArt.frame.size.height)];
  img.center = albumArt.center;
  NSTimeInterval fadeInDuration = 0.0;
  
  switch (whichImage) {
    case 1:
      img.image = [UIImage imageNamed:@"forward.png"];
      break;
    case 2:
      img.image = [UIImage imageNamed:@"rewind.png"];
      break;
    case 3:
      img.image = [UIImage imageNamed:@"play.png"];
//      fadeInDuration = 0.05;
      break;
    case 4:
      img.image = [UIImage imageNamed:@"pause.png"];
//      fadeInDuration = 0.05;
      break;
    default:
      break;
  }
  
  [self.view insertSubview:img aboveSubview:albumArt];
  img.alpha = 0.0;
  
  [UIView animateWithDuration:fadeInDuration
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{img.alpha = 1.0;}
                   completion:^(BOOL finished){
                                if (finished) {
                                  [UIView animateWithDuration:1.0
                                                        delay:0.3
                                                      options:UIViewAnimationOptionCurveEaseOut
                                                   animations:^{img.alpha = 0.0;}
                                                   completion:^(BOOL finished){
                                                                if (finished) {
                                                                  [img removeFromSuperview];
                                                                }
                                                                }];
                                }
                              }];
}






- (void)getSongURL {
  int numberOfResults = 1;
  NSString *searchString = [NSString stringWithFormat:@"%@ %@", [nowPlaying getSongTitle], [nowPlaying getArtist]];
  
  NSString *encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *finalSearchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=song&entity=musicTrack&limit=%d", encodedSearchString, numberOfResults];
  
  NSURL *searchURL = [NSURL URLWithString:finalSearchString];
  
  NSError *error = nil;
  NSData *data = [[NSData alloc] initWithContentsOfURL:searchURL options:NSDataReadingUncached error:&error];
  
  if (data && !error) {
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *array = [JSON objectForKey:@"results"];
    NSDictionary *firstResult = array[0];
    NSString *trackViewURL = [firstResult objectForKey:@"trackViewUrl"];
    if (trackViewURL) {
      NSString *urlString = [NSString stringWithFormat:@"%@&app=music", trackViewURL];
      self.songURL = [NSURL URLWithString:urlString];
    }
    else {
      self.songURL = nil;
    }
  }

}



// ****************************************
// Post in background: http://stackoverflow.com/questions/9423447/ios-5-twitter-framework-tweeting-without-user-input-and-confirmation-modal-vie
// ****************************************

- (IBAction)tweetButton:(id)sender {
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"Getting Link...";
  hud.color = self.colorPicker.backgroundColor;
  hud.labelColor = self.colorPicker.secondaryTextColor;
  hud.activityIndicatorColor = self.colorPicker.secondaryTextColor;
  hud.dimBackground = YES;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self createTweetSheet];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
  });
}



-(void)createTweetSheet {
  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    _tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSString *message = [NSString stringWithFormat:@"Listening to %@ by %@", [nowPlaying getSongTitle], [nowPlaying getArtist]];
    [_tweetSheet setInitialText:message];
    
    [self getSongURL];
    NSLog(@"%@", self.songURL);
    [self.tweetSheet addURL:self.songURL];
    
    CGSize artworkImageViewSize = albumArt.bounds.size;
    [_tweetSheet addImage:[nowPlaying getAlbumArt:artworkImageViewSize]];
    
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result)
    {
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
      }
      
      [_tweetSheet dismissViewControllerAnimated:YES completion:nil];
    };
    
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
  
  UIImage *image = [UIImage imageNamed:@"twitter.png"];
  self.twitterLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tweetBox.frame.size.height - 10, self.tweetBox.frame.size.height - 10)];
  self.twitterLogo.image = image;
  [self.tweetBox addSubview:self.twitterLogo];
  [self.twitterLogo setCenter:CGPointMake(self.view.frame.size.width / 2, self.tweetBox.frame.size.height / 2)];
  
  [self setNeedsStatusBarAppearanceUpdate];
  
  if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"]) {
    [self showTutorial];
  }
  
  nowPlaying = [[NowPlaying alloc] init];
  self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
  
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





- (void)setBackgroundColor:(UIImage*)image {
  _colorPicker = [[DBImageColorPicker alloc] initFromImage:image withBackgroundType:DBImageColorPickerBackgroundTypeDefault];
  self.view.backgroundColor = [_colorPicker backgroundColor];
}





- (void)showTutorial {
  self.tutorial = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial.png"]];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeOutTutorial)];
  tap.numberOfTapsRequired = 1;
  [self.tutorial addGestureRecognizer:tap];
  
//  UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hey there!"
//                                                       message:@"Tap the Tweet button to share the song you're listening to on Twitter. The album art and a link to the song will be included.\n\nTap the album art to play/pause.\n\nSwipe left to go the next song, and right to go to the previous one."
//                                                      delegate:self
//                                             cancelButtonTitle:@"OK"
//                                             otherButtonTitles:nil, nil];
//  [errorAlert show];
//  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunch"];
}




- (void)fadeOutTutorial {
  [UIView animateWithDuration:1.0
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{self.tutorial.alpha = 0.0;}
                   completion:^(BOOL finished){
                                if (finished) {
                                  [self.tutorial removeFromSuperview];
                                }
                   }];
}

@end
