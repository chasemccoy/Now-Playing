//
//  NowPlayingDelegate.m
//  Now Playing
//
//  Created by Chase McCoy on 7/17/15.
//  Copyright © 2015 Chase McCoy. All rights reserved.
//

#import "NowPlayingDelegate.h"

@implementation NowPlaying

- (NSString*)getSongTitle {
  MPMediaItem *currentSong = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
  _title = [currentSong valueForProperty:MPMediaItemPropertyTitle];
  return _title;
}

- (NSString*)getArtist {
  MPMediaItem *currentSong = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
  _artist = [currentSong valueForProperty:MPMediaItemPropertyArtist];
  return _artist;
}

- (UIImage*)getAlbumArt:(CGSize)size {
  MPMediaItem *currentSong = [[MPMusicPlayerController systemMusicPlayer] nowPlayingItem];
  MPMediaItemArtwork *artwork = [currentSong valueForProperty:MPMediaItemPropertyArtwork];
  _albumArt = [artwork imageWithSize:size];
  return _albumArt;
}


@end
