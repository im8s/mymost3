//
//  JXSearchFileLogCell.m
//  shiku_im
//
//  Created by p on 2019/4/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSearchFileLogCell.h"
#import "UIImageView+FileType.h"
@interface JXSearchFileLogCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *sendTime;
@property (nonatomic, strong) UIImageView *fileImageView;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *tip;
@property (nonatomic, strong) UIView *line;

@end
@implementation JXSearchFileLogCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
        self.headImageView.layer.cornerRadius = 2.0;
        self.headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 10, self.headImageView.frame.origin.y, 200, self.headImageView.frame.size.height)];
        self.userName.textColor = [UIColor lightGrayColor];
        self.userName.font = [UIFont systemFontOfSize:16.0];
        self.userName.text = @"张辉";
        [self.contentView addSubview:self.userName];
        
        self.sendTime = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 200 - 15, self.headImageView.frame.origin.y, 200, self.headImageView.frame.size.height)];
        self.sendTime.textAlignment = NSTextAlignmentRight;
        self.sendTime.textColor = [UIColor lightGrayColor];
        self.sendTime.font = [UIFont systemFontOfSize:14.0];
        self.sendTime.text = @"2019/2/19";
        [self.contentView addSubview:self.sendTime];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.headImageView.frame) + 10, JX_SCREEN_WIDTH - 30, 80)];
        view.backgroundColor = HEXCOLOR(0xf0f0f0);
        [self.contentView addSubview:view];
        
        self.fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
        [view addSubview:self.fileImageView];
        
        self.fileName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fileImageView.frame) + 10, self.fileImageView.frame.origin.y, view.frame.size.width - CGRectGetMaxX(self.fileImageView.frame) - 10 - 15, 25)];
        self.fileName.textColor = [UIColor blackColor];
        self.fileName.font = [UIFont systemFontOfSize:16.0];
        self.fileName.text = @"源文件.zip";
        [view addSubview:self.fileName];
        
        
        self.tip = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fileImageView.frame) + 10, CGRectGetMaxY(self.fileName.frame), view.frame.size.width - CGRectGetMaxX(self.fileImageView.frame) - 10 - 15, 25)];
        self.tip.textColor = [UIColor blackColor];
        self.tip.font = [UIFont systemFontOfSize:14.0];
//        self.tip.text = @"docx 464KB";
        [view addSubview:self.tip];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(15, 149.5, JX_SCREEN_WIDTH - 15, LINE_WH)];
        self.line.backgroundColor = THEMECOLOR;
        [self.contentView addSubview:self.line];
        
    }
    return self;
}

- (void)setMsg:(JXMessageObject *)msg {
    _msg = msg;
    self.userName.text = msg.fromUserName;
    [g_server getHeadImageLarge:msg.fromUserId userName:msg.fromUserName imageView:self.headImageView getHeadHandler:nil];
    self.sendTime.text = [TimeUtil getTimeStrStyle1:[msg.timeSend timeIntervalSince1970]];
    
    switch (self.type) {
        case FileLogType_file:{

            self.fileName.text = [msg.content lastPathComponent];
            NSString * fileExt = [msg.content pathExtension];
            NSInteger fileType = [self fileTypeWithExt:fileExt];
            [self.fileImageView setFileType:fileType];
            self.tip.text = [NSString stringWithFormat:@"%.02fKB",[msg.fileSize longValue]/1000.0];
            
        }
            
            break;
        case FileLogType_Link:{
            
            if ([msg.type integerValue] == kWCMessageTypeShare) {
                NSDictionary * msgDict = [[[SBJsonParser alloc]init]objectWithString:self.msg.objectId];
                self.fileName.text = [msgDict objectForKey:@"title"];
                self.tip.text = [msgDict objectForKey:@"subTitle"];
                [self.fileImageView sd_setImageWithURL:[NSURL URLWithString:[msgDict objectForKey:@"imageUrl"]] placeholderImage:[UIImage imageNamed:@"unkown"]];
            }else {
                SBJsonParser * parser = [[SBJsonParser alloc] init] ;
                NSDictionary *content = [parser objectWithString:self.msg.content];
                self.fileName.text = [content objectForKey:@"title"];
                self.tip.text = @"";
                [self.fileImageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:@"unkown"]];
            }
        }
            
            break;
        case FileLogType_transact:{
            if ([msg.type integerValue] == kWCMessageTypeRedPacket) {
                self.fileName.text = msg.content;
                self.tip.text = @"";
                self.fileImageView.image = [UIImage imageNamed:@"hongb"];
            }else {
                self.fileName.text = [NSString stringWithFormat:@"￥ %@",msg.content];
                self.tip.text = msg.fileName;
                self.fileImageView.image = [UIImage imageNamed:@"transferAccounts"];
            }
        }
            
            break;
            
        default:
            break;
    }
}
-(int)fileTypeWithExt:(NSString *)fileExt{
    int fileType = 0;
    if ([fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"gif"] || [fileExt isEqualToString:@"bmp"])
        fileType = 1;
    else if ([fileExt isEqualToString:@"amr"] || [fileExt isEqualToString:@"mp3"] || [fileExt isEqualToString:@"wav"])
        fileType = 2;
    else if ([fileExt isEqualToString:@"mp4"] || [fileExt isEqualToString:@"mov"])
        fileType = 3;
    else if ([fileExt isEqualToString:@"ppt"] || [fileExt isEqualToString:@"pptx"])
        fileType = 4;
    else if ([fileExt isEqualToString:@"xls"] || [fileExt isEqualToString:@"xlsx"])
        fileType = 5;
    else if ([fileExt isEqualToString:@"doc"] || [fileExt isEqualToString:@"docx"])
        fileType = 6;
    else if ([fileExt isEqualToString:@"zip"] || [fileExt isEqualToString:@"rar"])
        fileType = 7;
    else if ([fileExt isEqualToString:@"txt"])
        fileType = 8;
    else if ([fileExt isEqualToString:@"pdf"])
        fileType = 10;
    else
        fileType = 9;
    return fileType;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
