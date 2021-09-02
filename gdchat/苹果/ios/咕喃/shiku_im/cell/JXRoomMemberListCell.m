//
//  JXRoomMemberListCell.m
//  shiku_im
//
//  Created by p on 2018/7/3.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXRoomMemberListCell.h"

@interface JXRoomMemberListCell()

@property (nonatomic, strong) JXImageView *headImageView;
@property (nonatomic, strong) UILabel *roleLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation JXRoomMemberListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customView];
    }
    return self;
}

- (void)customView {
    
    _headImageView = [[JXImageView alloc]init];
    _headImageView.userInteractionEnabled = NO;
    _headImageView.delegate = self;
//    _headImageView.didTouch = @selector(headImageDidTouch);
    _headImageView.frame = CGRectMake(15,9.5,40,40);
    _headImageView.layer.cornerRadius = 5;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.contentView addSubview:self.headImageView];
    
    _roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10, 0, 50, 15)];
    _roleLabel.center = CGPointMake(_roleLabel.center.x, _headImageView.center.y);
    _roleLabel.textColor = [UIColor whiteColor];
    _roleLabel.textAlignment = NSTextAlignmentCenter;
    _roleLabel.text = Localized(@"JXGroup_RoleNormal");
    _roleLabel.font = [UIFont systemFontOfSize:10.0];
    _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
    _roleLabel.layer.cornerRadius = 2.0;
    _roleLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:_roleLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_roleLabel.frame) + 10, 0, 200, 20)];
    _nameLabel.center = CGPointMake(_nameLabel.center.x, _roleLabel.center.y);
    _nameLabel.font = [UIFont systemFontOfSize:16.0];
    [self.contentView addSubview:_nameLabel];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(65, 59 - LINE_WH, JX_SCREEN_WIDTH-65, LINE_WH)];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [self.contentView addSubview:_lineView];
    
}

- (void)setData:(memberData *)data {
    _data = data;
    
    [g_server getHeadImageSmall:[NSString stringWithFormat:@"%ld", data.userId] userName:data.userNickName imageView:_headImageView getHeadHandler:nil];
    
    NSString *str = Localized(@"JXGroup_RoleNormal");
    _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
    switch (self.role) {
        case 1:{
            str = Localized(@"JXGroup_Owner");
            _roleLabel.backgroundColor = HEXCOLOR(0xf9cd0a);
        }
            break;
        case 2:{
            str = Localized(@"JXGroup_Admin");
            _roleLabel.backgroundColor = HEXCOLOR(0x36d55c);
        }
            break;
        case 4:{ //隐身人
            str = Localized(@"JXInvisibleMan");
            _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
        }
            break;
        case 5:{ //监控人
            str = Localized(@"JXMonitorPerson");
            _roleLabel.backgroundColor = HEXCOLOR(0x3db4ff);
        }
            break;

        default:
            break;
    }
    _roleLabel.text = str;
    CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _roleLabel.font} context:nil].size;
    _roleLabel.frame = CGRectMake(_roleLabel.frame.origin.x, _roleLabel.frame.origin.y, size.width + 5, _roleLabel.frame.size.height);
    _nameLabel.frame = CGRectMake(CGRectGetMaxX(_roleLabel.frame) + 10, _nameLabel.frame.origin.y, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    
    
    JXUserObject *allUser = [[JXUserObject alloc] init];
    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
    if ([_curManager isEqualToString:MY_USER_ID]) {
        _nameLabel.text = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
    }else {
        _nameLabel.text = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName;
    }
    memberData *mData = [self.room getMember:g_myself.userId];

    if (!self.room.allowSendCard && [mData.role intValue] != 1 && [mData.role intValue] != 2) {
        _nameLabel.text = [_nameLabel.text substringToIndex:[_nameLabel.text length]-1];
        _nameLabel.text = [_nameLabel.text stringByAppendingString:@"*"];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
