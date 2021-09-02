//
//  JXFileViewController.m
//  shiku_im
//
//  Created by 1 on 17/7/4.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXFileViewController.h"
#import "JXShareFileTableViewCell.h"
#import "JXShareFileObject.h"
#import "JX_DownListView.h"
#import "JXFileDetailViewController.h"
#import "MCDownloader.h"
#import "QBImagePickerController.h"
//#import <AssetsLibrary/ALAssetsLibrary.h>

@interface JXFileViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSIndexPath * currentIndexpath;

@property (nonatomic, strong) UIButton * addFileButton;


@end

@implementation JXFileViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.isGotoBack = YES;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.title = Localized(@"JXRoomMemberVC_ShareFile");
        _dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    [self customView];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.tableFooterView = [[UIView alloc] init];
    [_table registerClass:[JXShareFileTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JXShareFileTableViewCell class])];
    [self getServerData];
    
}

-(void)customView{
    if (!_addFileButton){
        NSString *image = THESIMPLESTYLE ? @"im_003_more_button_black" : @"im_003_more_button_normal";
        _addFileButton = [UIFactory createButtonWithImage:image
                                                highlight:nil
                                                   target:self
                                                 selector:@selector(addNewShareFile)];
        
        _addFileButton.frame = CGRectMake(JX_SCREEN_WIDTH-15-18, JX_SCREEN_TOP-15-18, 18, 18);
        [self.tableHeader addSubview:_addFileButton];
    }
}

-(void)getServerData{
    [g_server roomShareListRoomId:_room.roomId userId:nil pageSize:12 pageIndex:_page toView:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXShareFileTableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JXShareFileTableViewCell class]) forIndexPath:indexPath];
    
    JXShareFileObject * fileObject = _dataArray[indexPath.row];
    [cell setShareFileListCellWith:fileObject indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    JXShareFileObject * fileObject = _dataArray[indexPath.row];
    memberData * myMem = nil;
    for (memberData * member in _room.members) {
        if ([[NSString stringWithFormat:@"%ld",member.userId] isEqualToString:g_myself.userId]) {
            myMem = member;
            break;
        }
    }
    
    if ([myMem.role integerValue] <= 2 || [fileObject.userId isEqualToString:g_myself.userId]) {
        return YES;
    }else{
        return NO;
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXShareFileObject *obj = _dataArray[indexPath.row];
    memberData * myMem = nil;
    for (memberData * member in _room.members) {
        if ([[NSString stringWithFormat:@"%ld",member.userId] isEqualToString:g_myself.userId]) {
            myMem = member;
            break;
        }
    }
    if ([myMem.role integerValue] <= 2 || [obj.userId isEqualToString:MY_USER_ID]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JXShareFileObject * fileObject = _dataArray[indexPath.row];
        _currentIndexpath = indexPath;
        [g_server roomShareDeleteRoomId:self.room.roomId shareId:fileObject.shareId toView:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    JXShareFileObject * shareFile = _dataArray[indexPath.row];
    JXFileDetailViewController * detailVC = [[JXFileDetailViewController alloc] init];
    detailVC.shareFile = shareFile;
//    [g_window addSubview:detailVC.view];
    [g_navigation pushViewController:detailVC animated:YES];
}

#pragma mark - Network
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    
    [self stopLoading];
    
    if([aDownload.action isEqualToString:act_shareList]){
        if (_page == 0) {
            [_dataArray removeAllObjects];
        }
        NSMutableArray * tempAray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in array1) {
            JXShareFileObject * shareFile = [JXShareFileObject shareFileWithDict:dict];
            [tempAray addObject:shareFile];
        }
        if (tempAray.count > 0) {
            [_dataArray addObjectsFromArray:tempAray];
        }
        [_table reloadData];
    }else if([aDownload.action isEqualToString:act_shareAdd]){
        [dict setValue:self.room.roomId forKey:@"roomId"];
        JXShareFileObject * shareFile = [JXShareFileObject shareFileWithDict:dict];
        [_dataArray addObject:shareFile];
        [_table reloadData];
    }else if([aDownload.action isEqualToString:act_shareGet]){
        
    }else if([aDownload.action isEqualToString:act_shareDelete]){
        [g_server showMsg:Localized(@"JXFile_deleteRoomFileSuccess")];
        [_dataArray removeObjectAtIndex:_currentIndexpath.row];
        [_table deleteRowsAtIndexPaths:@[_currentIndexpath] withRowAnimation:UITableViewRowAnimationRight];
    }else if ([aDownload.action isEqualToString:act_UploadFile]){
        NSArray * listArray = @[@"audios",@"images",@"others",@"videos"];
        NSString * fileUrl = nil;
        NSString * fileName = nil;
        NSInteger fileType = 0;
        int tbreak = 0;
        for (int i = 0; i<listArray.count; i++) {
            NSArray * dataArray = [dict objectForKey:listArray[i]];
            if ([dataArray count]) {
                for (NSDictionary * dataDict in dataArray) {
                    fileUrl = dataDict[@"oUrl"];
                    fileName = dataDict[@"oFileName"];
                    tbreak = 1;
                    switch (i) {
                        case 0:
                            fileType = 2;//音频
                            break;
                        case 1:
                            fileType = 1;//图片
                            break;
                        case 2:
                            fileType = 9;//其他
                            break;
                        case 3:
                            fileType = 3;//视频
                            break;
                        default:{
                            NSString * fileExt = [fileName pathExtension];
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
                            
                            break;
                        }
                    }
                }
            }
            if (tbreak == 1){
                break;
            }
        }
        
        [g_server roomShareAddRoomId:_room.roomId url:fileUrl fileName:fileName size:[NSNumber numberWithLong:aDownload.uploadDataSize] type:fileType toView:self];
    }
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    if ([aDownload.action isEqualToString:act_UploadFile]) {
        [_wait start:Localized(@"JXFile_uploading")];
    }else{
        [_wait start];
    }
}

#pragma mark ----------图片选择完成-------------
//UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([picker isMemberOfClass:[QBImagePickerController class]]) {
        if (info[@"UIImagePickerControllerMediaType"] == ALAssetTypeVideo){
//            NSURL * videoUrl = info[@"UIImagePickerControllerReferenceURL"];
        }
    }else{
        UIImage  * chosedImage=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    UIImage  * editedImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    //    int imageWidth = chosedImage.size.width;
    //    int imageHeight = chosedImage.size.height;
        [self dismissViewControllerAnimated:NO completion:^{
            NSString* file = [FileInfo getUUIDFileName:@"jpg"];
            [g_server saveImageToFile:chosedImage file:file isOriginal:NO];
            [g_server uploadFile:file validTime:@"-1" messageId:nil toView:self];
        }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{

    }];
}


#pragma mark - actions
-(void)addNewShareFile{
    memberData *data = [self.room getMember:g_myself.userId];
    BOOL flag = [data.role intValue] == 1 || [data.role intValue] == 2;
    if (!flag && !self.room.allowUploadFile) {
        [g_App showAlert:Localized(@"JX_NotUploadSharedFiles")];
        return;
    }
    if ([data.role integerValue] == 4) {
        //隐身人不能上传共享文件
        [JXMyTools showTipView:Localized(@"JX_InvisiblePeopleCannotUploadField")];
        return;
    }

    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect moreFrame = [self.tableHeader convertRect:_addFileButton.frame toView:window];
    
    JX_DownListView * downListView = [[JX_DownListView alloc] initWithFrame:self.view.bounds];
//    downListView.listContents = @[@"上传文件",@"上传图片",@"上传视频"];
//    downListView.listImages = @[@"me_press",@"me_press",@"me_press"];
     downListView.listContents = @[Localized(@"JXFile_uploadPhoto")];
//    Localized(@"JXFile_uploadVideo")
    __weak typeof(self) weakSelf = self;
    [downListView downlistPopOption:^(NSInteger index, NSString *content) {
//        if (index == 0) {
//            [weakSelf showSelLocalFileView];
//        }else if (index == 1) {
            [weakSelf showSelImagePicker];
//        }else if (index == 1) {
//            [weakSelf showSelVideo];
//        }
     
    } whichFrame:moreFrame animate:YES];
    [downListView show];
}

-(void)showSelLocalFileView{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:MCDownloadCacheFolderName];
    NSDirectoryEnumerator<NSString *> * myDirectoryEnumerator;
    myDirectoryEnumerator=  [fileManager enumeratorAtPath:strPath];
    
    while (strPath = [myDirectoryEnumerator nextObject]) {
        for (NSString * namePath in strPath.pathComponents) {
            NSLog(@"-----AAA-----%@", namePath  );
        }
    }
}

-(void)showSelImagePicker{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    ipc.modalPresentationStyle = UIModalPresentationFullScreen;
    //    [g_window addSubview:ipc.view];
    if (IS_PAD) {
        UIPopoverController *pop =  [[UIPopoverController alloc] initWithContentViewController:ipc];
        [pop presentPopoverFromRect:CGRectMake((self.view.frame.size.width - 320) / 2, 0, 300, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else {
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

-(void)showSelVideo{
    QBImagePickerController * videoPick = [[QBImagePickerController alloc] init];
    videoPick.filterType = QBImagePickerFilterTypeAllVideos;
    videoPick.delegate = self;
    videoPick.showsCancelButton = YES;
    videoPick.fullScreenLayoutEnabled = YES;
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoPick];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    
//    ALAssetsLibrary *library1 = [[ALAssetsLibrary alloc] init];
//    [library1 enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group) {
//            [group setAssetsFilter:[ALAssetsFilter allVideos]];
//            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                
//                if (result) {
//                    AlbumVideoInfo *videoInfo = [[AlbumVideoInfo alloc] init];
//                    videoInfo.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
//                    //                    videoInfo.videoURL = [result valueForProperty:ALAssetPropertyAssetURL];
//                    videoInfo.videoURL = result.defaultRepresentation.url;
//                    videoInfo.duration = [result valueForProperty:ALAssetPropertyDuration];
//                    videoInfo.name = [self getFormatedDateStringOfDate:[result valueForProperty:ALAssetPropertyDate]];
//                    videoInfo.size = result.defaultRepresentation.size; //Bytes
//                    videoInfo.format = [result.defaultRepresentation.filename pathExtension];
//                    [_albumVideoInfos addObject:videoInfo];
//                }
//            }];
//        } else {
//            //没有更多的group时，即可认为已经加载完成。
//            NSLog(@"after load, the total alumvideo count is %ld",_albumVideoInfos.count);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showAlbumVideos];
//            });
//        }
//        
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Failed.");
//    }];
}

@end
