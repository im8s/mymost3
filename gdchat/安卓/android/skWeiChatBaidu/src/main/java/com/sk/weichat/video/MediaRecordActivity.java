/**
 * Todo  同VideoRecorderActivity
 * <p>
 * 聊天界面视频录制类
 * create by TAG
 * update time 2018-11-21 19:43:13
 * <p>
 * 录制监听器
 * <p>
 * 录制监听器
 * <p>
 * 聊天界面视频录制类
 * create by TAG
 * update time 2018-11-21 19:43:13
 * <p>
 * 录制监听器
 * <p>
 * 录制监听器
 */
/*
package com.sk.weichat.video;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Camera;
import android.hardware.SensorManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.OrientationEventListener;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.alibaba.fastjson.JSON;
import com.bumptech.glide.Glide;
import com.cgfay.cameralibrary.adapter.PreviewFilterAdapter;
import com.cgfay.cameralibrary.engine.camera.CameraEngine;
import com.cgfay.cameralibrary.engine.camera.CameraParam;
import com.cgfay.cameralibrary.engine.listener.OnCameraCallback;
import com.cgfay.cameralibrary.engine.listener.OnCaptureListener;
import com.cgfay.cameralibrary.engine.listener.OnFpsListener;
import com.cgfay.cameralibrary.engine.listener.OnRecordListener;
import com.cgfay.cameralibrary.engine.model.GalleryType;
import com.cgfay.cameralibrary.engine.recorder.PreviewRecorder;
import com.cgfay.cameralibrary.engine.render.PreviewRenderer;
import com.cgfay.cameralibrary.utils.PathConstraints;
import com.cgfay.cameralibrary.widget.CainSurfaceView;
import com.cgfay.filterlibrary.glfilter.color.bean.DynamicColor;
import com.cgfay.filterlibrary.glfilter.resource.FilterHelper;
import com.cgfay.filterlibrary.glfilter.resource.ResourceJsonCodec;
import com.cgfay.filterlibrary.glfilter.utils.BitmapUtils;
import com.cjt2325.cameralibrary.CaptureLayout;
import com.cjt2325.cameralibrary.listener.CaptureListener;
import com.cjt2325.cameralibrary.listener.ClickListener;
import com.cjt2325.cameralibrary.listener.TypeListener;
import com.sk.weichat.AppConstant;
import com.sk.weichat.R;
import com.sk.weichat.Reporter;
import com.sk.weichat.adapter.MessageLocalVideoFile;
import com.sk.weichat.adapter.MessageVideoFile;
import com.sk.weichat.bean.VideoFile;
import com.sk.weichat.helper.DialogHelper;
import com.sk.weichat.ui.base.BaseActivity;
import com.sk.weichat.ui.me.LocalVideoActivity;
import com.sk.weichat.util.BitmapUtil;
import com.sk.weichat.util.CameraUtil;
import com.sk.weichat.util.FileUtil;
import com.sk.weichat.util.ScreenUtil;

import java.io.File;
import java.nio.ByteBuffer;
import java.util.List;

import de.greenrobot.event.EventBus;
import fm.jiecao.jcvideoplayer_lib.JCVideoViewbyXuan;
import me.kareluo.imaging.IMGEditActivity;

*/
/**
 * 聊天界面视频录制类
 * create by TAG
 * update time 2018-11-21 19:43:13
 * <p>
 * 录制监听器
 *//*


public class MediaRecordActivity extends BaseActivity implements View.OnClickListener {
    public static final int REQUEST_IMAGE_EDIT = 1;
    private static final int REQUEST_CODE_SELECT_VIDEO = 3;
    // 录制时长限制
    private static final int mRecordMaxTime = 10 * 1000;
    private static final int mRecordMinTime = 100;
    public int mOrientation = 180;
    // ------------------------------------  选择滤镜返回 ---------------------------------------------
    PreviewFilterAdapter.OnFilterChangeListener mFilterListener = resourceData -> {
        if (!resourceData.name.equals("none")) {
            String folderPath = FilterHelper.getFilterDirectory(MediaRecordActivity.this) + File.separator + resourceData.unzipFolder;
            DynamicColor color = null;
            try {
                color = ResourceJsonCodec.decodeFilterData(folderPath);
            } catch (Exception e) {
                e.printStackTrace();
            }
            PreviewRenderer.getInstance().changeDynamicFilter(color);
        } else {
            PreviewRenderer.getInstance().changeDynamicFilter(null);
        }

    };
    // 主线程Handler
    private Handler mMainHandler;
    // 预览参数
    private CameraParam mCameraParam;
    private int mCurrentTime;
    // 控件
    private CainSurfaceView mCameraSurfaceView;
    private CaptureLayout mCaptureLayout;
    private FilterSelectDialog mFilterDialog;
    // 图片预览
    private ImageView mPhotoView;
    // 视频预览
    private JCVideoViewbyXuan mVideoView;
    private boolean isTakePhoto;// 当前为 拍照 || 录像
    private String mCurrentPath;
    private RelativeLayout mRlSetBar;
    private String mEditedImagePath;

    //    private FoucsView mFoucsView;
    */
/**
 * 录制监听器
 *//*

    private OnRecordListener mRecordListener = new OnRecordListener() {

        @Override
        public void onRecordStarted() {
            // 编码器已经进入录制状态，则快门按钮可用
        }

        @Override
        public void onRecordProgressChanged(final long duration) {
        }

        @Override
        public void onRecordFinish() {
            // 编码器已经完全释放，则快门按钮可用
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    playVideo();
                }
            });
        }
    };
    // ------------------------------------ 预览回调 ---------------------------------------------
    private OnCameraCallback mCameraCallback = new OnCameraCallback() {

        @Override
        public void onCameraOpened() {
            // 相机打开之后准备检测器

        }

        @Override
        public void onPreviewCallback(byte[] data) {
            // 人脸检测
            //     FaceTracker.getInstance().trackFace(data,mCameraParam.previewWidth, mCameraParam.previewHeight);
            // 请求刷新
            requestRender();
        }
    };
    // ------------------------------------ 拍照回调 ---------------------------------------------
    private OnCaptureListener mCaptureCallback = new OnCaptureListener() {
        @Override
        public void onCapture(final ByteBuffer buffer, final int width, final int height) {
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCurrentPath = PathConstraints.getImageCachePath(MediaRecordActivity.this);
                    BitmapUtils.saveBitmap(mCurrentPath, buffer, width, height);

                    Log.e("xuan", "拍照路径: " + mCurrentPath);
                    mPhotoView.setVisibility(View.VISIBLE);
                    Glide.with(MediaRecordActivity.this).load(mCurrentPath).into(mPhotoView);
                    mRlSetBar.setVisibility(View.GONE);
                    mCaptureLayout.startAlphaAnimation();
                    mCaptureLayout.startTypeBtnAnimator();
                }
            });
        }
    };
    private Camera mCamera;
    private AlbumOrientationEventListener mAlbumOrientationEventListener;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_media_record);

        int widht = ScreenUtil.getScreenWidth(this);
        int height = ScreenUtil.getScreenHeight(this);


        mCameraParam = CameraParam.getInstance();
        mCameraParam.setAspectRatio(widht, height);
        mMainHandler = new Handler(getMainLooper());

        mAlbumOrientationEventListener = new AlbumOrientationEventListener(this, SensorManager.SENSOR_DELAY_NORMAL);
        if (mAlbumOrientationEventListener.canDetectOrientation()) {
            mAlbumOrientationEventListener.enable();
        } else {
            Log.e("zx", "不能获取Orientation");
        }
        initView();
        initEvent();
        initCamera();


    }
    //    public boolean setFocusViewAnimation(float x, float y) {
    //        if (y > mCaptureLayout.getTop()) {
    //            return false;
    //        }
    //        mFoucsView.setVisibility(View.VISIBLE);
    //        if (x < mFoucsView.getWidth() / 2) {
    //            x = mFoucsView.getWidth() / 2;
    //        }
    //        if (x > ScreenUtil.getScreenWidth(this) - mFoucsView.getWidth() / 2) {
    //            x = ScreenUtil.getScreenWidth(this) - mFoucsView.getWidth() / 2;
    //        }
    //        if (y < mFoucsView.getWidth() / 2) {
    //            y = mFoucsView.getWidth() / 2;
    //        }
    //        if (y > mCaptureLayout.getTop() - mFoucsView.getWidth() / 2) {
    //            y = mCaptureLayout.getTop() - mFoucsView.getWidth() / 2;
    //        }
    //        mFoucsView.setX(x - mFoucsView.getWidth() / 2);
    //        mFoucsView.setY(y - mFoucsView.getHeight() / 2);
    //        ObjectAnimator scaleX = ObjectAnimator.ofFloat(mFoucsView, "scaleX", 1, 0.6f);
    //        ObjectAnimator scaleY = ObjectAnimator.ofFloat(mFoucsView, "scaleY", 1, 0.6f);
    //        ObjectAnimator alpha = ObjectAnimator.ofFloat(mFoucsView, "alpha", 1f, 0.4f, 1f, 0.4f, 1f, 0.4f, 1f);
    //        AnimatorSet animSet = new AnimatorSet();
    //        animSet.play(scaleX).with(scaleY).before(alpha);
    //        animSet.setDuration(400);
    //        animSet.start();
    //
    //        handleFocus(x, y);
    //        return true;
    //    }

    private void handleFocus(float x, float y) {

        //        mMainHandler.postDelayed(new Runnable() {
        //            @Override
        ////            public void run() {
        ////                mFoucsView.setVisibility(View.GONE);
        ////            }
        //        }, 600);
    }

    private void initCamera() {
        // 初始化相机渲染引擎
        PreviewRenderer.getInstance()
                .setCameraCallback(mCameraCallback)
                .setCaptureFrameCallback(mCaptureCallback)
                .setFpsCallback(new OnFpsListener() {
                    @Override
                    public void onFpsCallback(float fps) {

                    }
                }).initRenderer(this);
    }

    private void requestRender() {
        PreviewRenderer.getInstance().requestRender();
    }

    private void initView() {

        mPhotoView = findViewById(R.id.image_photo);
        mVideoView = findViewById(R.id.video_preview);

        // mVideoView.setForceFullScreenPlay(true);
        //        mFoucsView = findViewById(R.id.fouce_view);
        mRlSetBar = findViewById(R.id.set_rl);
        //        findViewById(R.id.view_touch).setOnTouchListener(new View.OnTouchListener() {
        //            @Override
        //            public boolean onTouch(View v, MotionEvent event) {
        //                switch (event.getAction()) {
        //                    case MotionEvent.ACTION_DOWN:
        //                        Log.e("xuan", "onTouchEvent: " + event.getPointerCount());
        //                        if (event.getPointerCount() == 1) {
        //                            // 显示对焦指示器
        //                            setFocusViewAnimation(event.getX(), event.getY());
        //                        }
        //                        break;
        //                    case MotionEvent.ACTION_MOVE:
        //                        break;
        //                    case MotionEvent.ACTION_UP:
        //                        break;
        //                }
        //                return false;
        //            }
        //        });

        mCameraSurfaceView = findViewById(R.id.view_surface);
        mCameraSurfaceView.addOnTouchScroller(null);
        mCameraSurfaceView.addMultiClickListener(null);

        findViewById(R.id.iv_swith).setOnClickListener(this);
        findViewById(R.id.iv_filter).setOnClickListener(this);

        // 绑定需要渲染的SurfaceView
        PreviewRenderer.getInstance().setSurfaceView(mCameraSurfaceView);


        mFilterDialog = new FilterSelectDialog(this, mFilterListener);
    }

    private void initEvent() {

        mCaptureLayout = findViewById(R.id.capture_layout);
        mCaptureLayout.setIconSrc(0, R.drawable.ic_sel_local_video);
        mCaptureLayout.setDuration(mRecordMaxTime);
        mCaptureLayout.setMinDuration(mRecordMinTime);
        mCaptureLayout.setCaptureLisenter(new CaptureListener() {
            @Override
            public void takePictures() {

                mCamera = CameraEngine.getInstance().getCamera();

                mCamera.takePicture(null, null, new Camera.PictureCallback() {
                    @Override
                    public void onPictureTaken(byte[] data, Camera camera) {
                        Bitmap mCurrentBitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
                        if (mCameraParam.cameraId == 0) { // 后置摄像头拍摄出来的照片需要旋转90'
                            mCurrentBitmap = CameraUtil.restoreRotatedImage(90, mCurrentBitmap);
                        } else {// 前置摄像头拍出的图片需要先旋转270',在左右翻转一次
                            mCurrentBitmap = CameraUtil.restoreRotatedImage(270, mCurrentBitmap);
                            mCurrentBitmap = CameraUtil.turnCurrentLayer(mCurrentBitmap, -1, 1);
                            mCurrentBitmap = CameraUtil.restoreRotatedImage(mOrientation, mCurrentBitmap);
                        }

                        mCurrentPath = PathConstraints.getImageCachePath(MediaRecordActivity.this);
                        if (BitmapUtil.saveBitmapToSDCard(mCurrentBitmap, mCurrentPath)) {
                            Bitmap finalMCurrentBitmap = mCurrentBitmap;

                            mPhotoView.post(new Runnable() {
                                @Override
                                public void run() {
                                    isTakePhoto = true;
                                    mPhotoView.setVisibility(View.VISIBLE);
                                    mPhotoView.setImageBitmap(finalMCurrentBitmap);
                                    mRlSetBar.setVisibility(View.GONE);
                                    mCaptureLayout.startAlphaAnimation();
                                    mCaptureLayout.startTypeBtnAnimator();
                                    mCamera.startPreview();//相机预览
                                }
                            });
                        }
                    }
                });
            }

            @Override
            public void recordStart() {
                // 开始录制视频
                isTakePhoto = false;

                mRlSetBar.setVisibility(View.GONE);
                mCameraParam.mGalleryType = GalleryType.VIDEO;
                // 是否允许录制音频
                //    boolean enableAudio = mCameraParam.audioPermitted && mCameraParam.recordAudio
                //    && mCameraParam.mGalleryType == GalleryType.VIDEO;

                // 计算输入纹理的大小
                int width = mCameraParam.previewWidth;
                int height = mCameraParam.previewHeight;
                if (mCameraParam.orientation == 90 || mCameraParam.orientation == 270) {
                    width = mCameraParam.previewHeight;
                    height = mCameraParam.previewWidth;
                }

                mCurrentPath = PathConstraints.getVideoCachePath(MediaRecordActivity.this);                // 开始录制
                PreviewRecorder.getInstance().setMilliSeconds(PreviewRecorder.CountDownType.ThreeMinute);
                PreviewRecorder.getInstance()
                        .setRecordType(PreviewRecorder.RecordType.Video)
                        .setOutputPath(mCurrentPath)
                        .enableAudio(true)
                        .setRecordSize(width, height)
                        .setOnRecordListener(mRecordListener)
                        .startRecord();
            }

            @Override
            public void recordShort(long time) {
                // new CheckPermission().closeAudio();
                mCaptureLayout.setTextWithAnimation("录制时间过短");

            }

            @Override
            public void recordEnd(long time) {
                mCurrentTime = (int) (time / 1000);
                PreviewRecorder.getInstance().stopRecord(false);
            }

            @Override
            public void recordZoom(float zoom) {
                // 摄像头缩放
            }

            @Override
            public void recordError() {
                Log.e("recordError", "recordError: 录制失败");
            }
        });

        //确认 取消
        mCaptureLayout.setTypeLisenter(new TypeListener() {
            @Override
            public void cancel() {
                reset();
            }

            @Override
            public void confirm() {
                complete();
            }
        });

        mCaptureLayout.setLeftClickListener(new ClickListener() {
            @Override
            public void onClick() {
                // finish();
                mCamera.startPreview();
            }
        });

        mCaptureLayout.setMiddleClickListener(new ClickListener() {
            @Override
            public void onClick() {// 进行图片编辑
                if (!TextUtils.isEmpty(mCurrentPath)) {
                    mEditedImagePath = FileUtil.createImageFileForEdit().getAbsolutePath();
                    IMGEditActivity.startForResult(MediaRecordActivity.this, Uri.fromFile(new File(mCurrentPath)), mEditedImagePath, REQUEST_IMAGE_EDIT);
                } else {
                    DialogHelper.tip(MediaRecordActivity.this, "图片编辑失败");
                }
            }
        });

        mCaptureLayout.setRightClickListener(new ClickListener() {
            @Override
            public void onClick() {// 选择本地视频
                Intent intent = new Intent(MediaRecordActivity.this, LocalVideoActivity.class);
                intent.putExtra(AppConstant.EXTRA_ACTION, AppConstant.ACTION_SELECT);
                intent.putExtra(AppConstant.EXTRA_MULTI_SELECT, true);
                startActivityForResult(intent, REQUEST_CODE_SELECT_VIDEO);
            }
        });
    }

    */
/*
           预览视频
            *//*

    private void playVideo() {
        Log.e("xuan", "视频录制完成: " + mCurrentPath);
        mVideoView.setVisibility(View.VISIBLE);
        mVideoView.play(mCurrentPath);
//todo
    }

    private void reset() {

        if (isTakePhoto) {
            mPhotoView.setVisibility(View.GONE);
        } else {
            mVideoView.stop();// 停止播放 并释放资源
            mVideoView.setVisibility(View.GONE);
        }

        mRlSetBar.setVisibility(View.VISIBLE);
        mCaptureLayout.resetCaptureLayout();
    }

    private void complete() {
        if (isTakePhoto) {
            EventBus.getDefault().post(new MessageEventGpu(mCurrentPath));

        } else {

            // compress(mCurrentVideoPath);
            EventBus.getDefault().post(new MessageVideoFile(mCurrentTime,
                    new File(mCurrentPath).length(), mCurrentPath));
        }
        finish();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_filter:
                mFilterDialog.show();
                break;
            case R.id.iv_swith:
                changeCamera();
                break;
        }
    }

    private void changeCamera() {
        PreviewRenderer.getInstance().switchCamera();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            switch (requestCode) {
                case REQUEST_IMAGE_EDIT:
                    // 图片编辑返回
                    mCurrentPath = mEditedImagePath;
                    Glide.with(MediaRecordActivity.this).load(mCurrentPath).into(mPhotoView);
                    break;
                case REQUEST_CODE_SELECT_VIDEO:
                    // 选择视频返回
                    if (data == null) {
                        return;
                    }
                    String json = data.getStringExtra(AppConstant.EXTRA_VIDEO_LIST);
                    List<VideoFile> fileList = JSON.parseArray(json, VideoFile.class);
                    if (fileList == null || fileList.size() == 0) {
                        // 不可到达，列表里有做判断，
                        Reporter.unreachable();
                    } else {
                        for (VideoFile videoFile : fileList) {
                            String filePath = videoFile.getFilePath();
                            if (TextUtils.isEmpty(filePath)) {
                                // 不可到达，列表里有做过滤，
                                Reporter.unreachable();
                            } else {
                                File file = new File(filePath);
                                if (!file.exists()) {
                                    // 不可到达，列表里有做过滤，
                                    Reporter.unreachable();
                                } else {
                                    EventBus.getDefault().post(new MessageLocalVideoFile(file));
                                }
                            }
                        }
                        finish();
                    }
                    break;
                default:
                    super.onActivityResult(requestCode, resultCode, data);
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (PreviewRecorder.getInstance().isRecording()) {
            // 取消录制
            PreviewRecorder.getInstance().cancelRecording();
            mCaptureLayout.resetCaptureLayout();
        }

        if (mVideoView.getVisibility() == View.VISIBLE) {
            mVideoView.stop();
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mAlbumOrientationEventListener.disable();

        PreviewRecorder.getInstance().removeAllSubVideo();
        PreviewRecorder.getInstance().deleteRecordDuration();
        PreviewRecorder.getInstance().destroyRecorder();
    }

    private class AlbumOrientationEventListener extends OrientationEventListener {
        public AlbumOrientationEventListener(Context context) {
            super(context);
        }

        public AlbumOrientationEventListener(Context context, int rate) {
            super(context, rate);
        }

        @Override
        public void onOrientationChanged(int orientation) {
            if (orientation == OrientationEventListener.ORIENTATION_UNKNOWN) {
                return;
            }

            //保证只返回四个方向
            int newOrientation = ((orientation + 45) / 90 * 90) % 360;

            if (newOrientation != mOrientation) {
                mOrientation = newOrientation;
                Log.e("zx", "onOrientationChanged: " + mOrientation);
                //返回的mOrientation就是手机方向，为0°、90°、180°和270°中的一个

            }
        }
    }
}
*/
