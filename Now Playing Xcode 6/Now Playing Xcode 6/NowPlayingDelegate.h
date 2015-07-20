//
//  NowPlayingDelegate.h
//  Now Playing
//
//  Created by Chase McCoy on 7/17/15.
//  Copyright © 2015 Chase McCoy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MediaPlayer;

@interface NowPlaying : NSObject {
  
}

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *artist;
@property (retain, nonatomic) UIImage *albumArt;

- (NSString*)getSongTitle;
- (NSString*)getArtist;
- (UIImage*)getAlbumArt:(CGSize)size;

@end
