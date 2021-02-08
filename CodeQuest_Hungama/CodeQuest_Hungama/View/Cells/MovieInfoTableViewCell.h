//
//  MovieInfoTableViewCell.h
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 06/02/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieInfoTableViewCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *imgBanner;
@property(strong, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property(strong, nonatomic) IBOutlet UILabel *lblReleaseDate;
@property(strong, nonatomic) IBOutlet UILabel *lblOtherDetails;
@property(strong, nonatomic) IBOutlet UIButton *btnPlay;

@end

NS_ASSUME_NONNULL_END
