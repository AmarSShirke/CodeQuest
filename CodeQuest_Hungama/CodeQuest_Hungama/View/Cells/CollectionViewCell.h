//
//  CollectionViewCell.h
//  CodeQuest_Hungama
//
//  Created by Amar Shirke on 07/02/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblCastName;
@property (nonatomic, strong) IBOutlet UIImageView *imgCast;

@end

NS_ASSUME_NONNULL_END
