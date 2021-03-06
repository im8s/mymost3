package com.sk.weichat.ui.circle.range;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.core.view.GestureDetectorCompat;
import androidx.core.view.ViewCompat;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.alibaba.fastjson.JSON;
import com.sk.weichat.AppConstant;
import com.sk.weichat.R;
import com.sk.weichat.bean.Area;
import com.sk.weichat.bean.UploadFileResult;
import com.sk.weichat.helper.DialogHelper;
import com.sk.weichat.helper.ImageLoadHelper;
import com.sk.weichat.helper.LoginHelper;
import com.sk.weichat.helper.UploadService;
import com.sk.weichat.ui.account.LoginHistoryActivity;
import com.sk.weichat.ui.base.BaseActivity;
import com.sk.weichat.ui.circle.util.SendTextFilter;
import com.sk.weichat.ui.map.MapPickerActivity;
import com.sk.weichat.ui.tool.ButtonColorChange;
import com.sk.weichat.ui.tool.MultiImagePreviewActivity;
import com.sk.weichat.util.Constants;
import com.sk.weichat.util.DeviceInfoUtil;
import com.sk.weichat.util.SkinUtils;
import com.sk.weichat.util.ToastUtil;
import com.sk.weichat.video.EasyCameraActivity;
import com.sk.weichat.video.MessageEventGpu;
import com.sk.weichat.view.SquareCenterFrameLayout;
import com.sk.weichat.view.TipDialog;
import com.sk.weichat.view.photopicker.PhotoPickerActivity;
import com.sk.weichat.view.photopicker.SelectModel;
import com.sk.weichat.view.photopicker.intent.PhotoPickerIntent;
import com.xuan.xuanhttplibrary.okhttp.HttpUtils;
import com.xuan.xuanhttplibrary.okhttp.callback.BaseCallback;
import com.xuan.xuanhttplibrary.okhttp.result.ObjectResult;
import com.xuan.xuanhttplibrary.okhttp.result.Result;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;
import okhttp3.Call;
import top.zibin.luban.Luban;
import top.zibin.luban.OnCompressListener;


/**
 * ???????????? || ??????
 */
public class SendShuoshuoActivity extends BaseActivity implements View.OnClickListener {
    private static final int REQUEST_CODE_CAPTURE_PHOTO = 1;  // ??????
    private static final int REQUEST_CODE_PICK_PHOTO = 2;     // ??????
    private static final int REQUEST_CODE_SELECT_LOCATE = 3;  // ??????
    private static final int REQUEST_CODE_SELECT_TYPE = 4;    // ????????????
    private static final int REQUEST_CODE_SELECT_REMIND = 5;  // ????????????
    private static boolean isBoolBan = false;
    private final int mType = 1;
    private EditText mTextEdit;
    // ????????????
    private TextView mTVLocation;
    // ????????????
    private TextView mTVSee;
    // ????????????
    private TextView mTVAt;
    private ArrayList<String> mPhotoList;
    private String mImageData;
    // ???????????? || ???????????? ?????? ?????????????????????????????????
    private String str1;
    private String str2;
    private String str3;
    // ?????????????????????????????????Uri
    private Uri mNewPhotoUri;
    // ???????????????
    private int visible = 1;
    // ???????????? || ????????????
    private String lookPeople;
    // ????????????
    private String atlookPeople;
    // ??????????????????
    private double latitude;
    private double longitude;
    private String address;
    private String mShareContent;
    private CheckBox checkBox;
    private PostArticleImgAdapter postArticleImgAdapter;
    private ItemTouchHelper itemTouchHelper;
    private RecyclerView rcvImg;
    private TextView tv;
    private TextView tv_title_right;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_send_shuoshuo);
        mPhotoList = new ArrayList<>();
        postArticleImgAdapter = new PostArticleImgAdapter(this, mPhotoList);
        initActionBar();
        initView();
        initEvent();
        EventBus.getDefault().register(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }

    private void initActionBar() {
        getSupportActionBar().hide();
        findViewById(R.id.iv_title_left).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        TextView tvTitle = (TextView) findViewById(R.id.tv_title_center);
        tvTitle.setText(R.string.send_image_text);
        tv_title_right = (TextView) findViewById(R.id.tv_title_right);
        tv_title_right.setText(getResources().getString(R.string.circle_release));
        tv_title_right.setBackground(mContext.getResources().getDrawable(R.drawable.bg_btn_grey_circle));
        ViewCompat.setBackgroundTintList(tv_title_right, ColorStateList.valueOf(SkinUtils.getSkin(this).getAccentColor()));
        tv_title_right.setTextColor(getResources().getColor(R.color.white));
        tv_title_right.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPhotoList.size() <= 0 && TextUtils.isEmpty(mTextEdit.getText().toString())) {
                    return;
                }
                if (mPhotoList.size() <= 0) {
                    // ????????????
                    sendShuoshuo();
                } else {
                    // ????????????+??????
                    new UploadPhoto().execute();
                }
            }
        });
    }

    private void initView() {
        checkBox = findViewById(R.id.cb_ban);

        RelativeLayout rl_ban = findViewById(R.id.rl_ban);
        rl_ban.setOnClickListener(v -> {
            isBoolBan = !isBoolBan;
            checkBox.setChecked(isBoolBan);
            if (isBoolBan) {
                ButtonColorChange.checkChange(SendShuoshuoActivity.this, checkBox);
            } else {
                checkBox.setButtonDrawable(getResources().getDrawable(R.mipmap.prohibit_icon));
            }
        });
        checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
            isBoolBan = isChecked;
            checkBox.setChecked(isBoolBan);
            if (isBoolBan) {
                ButtonColorChange.checkChange(SendShuoshuoActivity.this, checkBox);
            } else {
                checkBox.setButtonDrawable(getResources().getDrawable(R.mipmap.prohibit_icon));
            }
        });

        mTextEdit = (EditText) findViewById(R.id.text_edit);
        // ??????EditText???ScrollView???????????????
        mTextEdit.setOnTouchListener((v, event) -> {
            v.getParent().requestDisallowInterceptTouchEvent(true);
            return false;
        });
        // ?????????EditText?????????????????????600????????????????????????
        mTextEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (mTextEdit.getText().toString().trim().length() >= 10000) {
                    Toast.makeText(mContext, getString(R.string.tip_edit_max_input_length, 10000), Toast.LENGTH_SHORT).show();
                }
            }
        });
        mTextEdit.setHint(getString(R.string.add_msg_mind));
        if (getIntent() != null) { // WebView??????????????????
            mShareContent = getIntent().getStringExtra(Constants.BROWSER_SHARE_MOMENTS_CONTENT);
            if (!TextUtils.isEmpty(mShareContent)) {
                mTextEdit.setText(mShareContent);
            }
        }

        rcvImg = (RecyclerView) findViewById(R.id.rcv_img);

        // ????????????
        mTVLocation = (TextView) findViewById(R.id.tv_location);
        // ????????????
        mTVSee = (TextView) findViewById(R.id.tv_see);
        // ????????????
        mTVAt = (TextView) findViewById(R.id.tv_at);

        tv = findViewById(R.id.tv);
        initRcv();
    }

    private void initRcv() {
        rcvImg.setLayoutManager(new StaggeredGridLayoutManager(3, StaggeredGridLayoutManager.VERTICAL));
        rcvImg.setAdapter(postArticleImgAdapter);
        MyCallBack myCallBack = new MyCallBack(tv, postArticleImgAdapter, mPhotoList, null);
        itemTouchHelper = new ItemTouchHelper(myCallBack);
        itemTouchHelper.attachToRecyclerView(rcvImg);//??????RecyclerView
        //????????????
        rcvImg.addOnItemTouchListener(new OnRecyclerItemClickListener(rcvImg) {

            @Override
            public void onItemClick(RecyclerView.ViewHolder vh) {
                int viewType = postArticleImgAdapter.getItemViewType(vh.getAdapterPosition());
                if (viewType == 1) {
                    showSelectPictureDialog();
                } else {
                    showPictureActionDialog(vh.getAdapterPosition());
                }
            }

            @Override
            public void onItemLongClick(RecyclerView.ViewHolder vh) {
                //??????item????????????????????????????????????
                if (vh.getLayoutPosition() != mPhotoList.size()) {
                    itemTouchHelper.startDrag(vh);
                }
            }
        });

        myCallBack.setDragListener(new DragListener() {
            @Override
            public void deleteState(boolean delete) {
                if (delete) {
                    tv.setBackgroundResource(R.color.holo_red_dark);
                    tv.setText(getResources().getString(R.string.post_delete_tv_s));
                } else {
                    tv.setText(getResources().getString(R.string.post_delete_tv_d));
                    tv.setBackgroundResource(R.color.holo_red_light);
                }
            }

            @Override
            public void dragState(boolean start) {
                if (start) {
                    tv.setVisibility(View.VISIBLE);
                } else {
                    tv.setVisibility(View.GONE);
                }
            }

            @Override
            public void clearView() {

            }
        });
    }

    private void initEvent() {
        if (coreManager.getConfig().disableLocationServer) {
            findViewById(R.id.rl_location).setVisibility(View.GONE);
        } else {
            findViewById(R.id.rl_location).setOnClickListener(this);
        }
        findViewById(R.id.rl_see).setOnClickListener(this);
        findViewById(R.id.rl_at).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.rl_location:
                // ????????????
                Intent intent1 = new Intent(this, MapPickerActivity.class);
                startActivityForResult(intent1, REQUEST_CODE_SELECT_LOCATE);
                break;
            case R.id.rl_see:
                // ????????????
                Intent intent2 = new Intent(this, SeeCircleActivity.class);
                intent2.putExtra("THIS_CIRCLE_TYPE", visible - 1);
                intent2.putExtra("THIS_CIRCLE_PERSON_RECOVER1", str1);
                intent2.putExtra("THIS_CIRCLE_PERSON_RECOVER2", str2);
                intent2.putExtra("THIS_CIRCLE_PERSON_RECOVER3", str3);
                startActivityForResult(intent2, REQUEST_CODE_SELECT_TYPE);
                break;
            case R.id.rl_at:
                // ????????????
                if (visible == 2) {
                    ToastUtil.showToast(SendShuoshuoActivity.this, R.string.tip_private_cannot_use_this);
                } else {
                    Intent intent3 = new Intent(this, AtSeeCircleActivity.class);
                    intent3.putExtra("REMIND_TYPE", visible);
                    intent3.putExtra("REMIND_PERSON", lookPeople);
                    intent3.putExtra("REMIND_SELECT_PERSON", atlookPeople);
                    startActivityForResult(intent3, REQUEST_CODE_SELECT_REMIND);
                }
                break;
        }
    }

    private void showSelectPictureDialog() {
        String[] items = new String[]{getString(R.string.photograph), getString(R.string.album)};
        AlertDialog.Builder builder = new AlertDialog.Builder(this).setSingleChoiceItems(items, 0,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (which == 0) {
                            takePhoto();
                        } else {
                            selectPhoto();
                        }
                        dialog.dismiss();
                    }
                });
        builder.show();
    }

    private void showPictureActionDialog(final int position) {
        String[] items = new String[]{getString(R.string.look_over), getString(R.string.delete)};
        AlertDialog.Builder builder = new AlertDialog.Builder(this).setTitle(getString(R.string.image))
                .setSingleChoiceItems(items, 0, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (which == 0) {
                            // ??????
                            Intent intent = new Intent(SendShuoshuoActivity.this, MultiImagePreviewActivity.class);
                            intent.putExtra(AppConstant.EXTRA_IMAGES, mPhotoList);
                            intent.putExtra(AppConstant.EXTRA_POSITION, position);
                            intent.putExtra(AppConstant.EXTRA_CHANGE_SELECTED, false);
                            startActivity(intent);
                        } else {
                            // ??????
                            deletePhoto(position);
                        }
                        dialog.dismiss();
                    }
                });
        builder.show();
    }

    private void deletePhoto(final int position) {
        mPhotoList.remove(position);
        postArticleImgAdapter.notifyDataSetChanged();
    }

    // ??????
    private void takePhoto() {
      /*  mNewPhotoUri = CameraUtil.getOutputMediaFileUri(this, CameraUtil.MEDIA_TYPE_IMAGE);
        CameraUtil.captureImage(this, mNewPhotoUri, REQUEST_CODE_CAPTURE_PHOTO);*/
        Intent intent = new Intent(this, EasyCameraActivity.class);
        startActivity(intent);
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void helloEventBus(final MessageEventGpu message) {
        photograph(new File(message.event));
    }

    // ????????????????????????
    // private double latitude = MyApplication.getInstance().getBdLocationHelper().getLatitude();
    // private double longitude = MyApplication.getInstance().getBdLocationHelper().getLng();
    // private String address = MyApplication.getInstance().getBdLocationHelper().getAddress();

    /**
     * ??????
     * ??????????????????????????????
     */
    private void selectPhoto() {
        ArrayList<String> imagePaths = new ArrayList<>();
        PhotoPickerIntent intent = new PhotoPickerIntent(SendShuoshuoActivity.this);
        intent.setSelectModel(SelectModel.MULTI);
        // ????????????????????? ??????false
        intent.setShowCarema(false);
        // ????????????????????????????????????9
        intent.setMaxTotal(9 - mPhotoList.size());
        // ??????????????????????????? ????????????????????????
        intent.setSelectedPaths(imagePaths);
        // intent.setImageConfig(config);
        // ???????????????????????????true
        intent.setLoadVideo(false);
        startActivityForResult(intent, REQUEST_CODE_PICK_PHOTO);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_CAPTURE_PHOTO) {
            // ???????????? Todo ?????????????????????
            if (resultCode == Activity.RESULT_OK) {
                if (mNewPhotoUri != null) {
                    photograph(new File(mNewPhotoUri.getPath()));
                } else {
                    ToastUtil.showToast(this, R.string.c_take_picture_failed);
                }
            }
        } else if (requestCode == REQUEST_CODE_PICK_PHOTO) {
            // ??????????????????
            if (resultCode == Activity.RESULT_OK) {
                if (data != null) {
                    boolean isOriginal = data.getBooleanExtra(PhotoPickerActivity.EXTRA_RESULT_ORIGINAL, false);
                    album(data.getStringArrayListExtra(PhotoPickerActivity.EXTRA_RESULT), isOriginal);
                } else {
                    ToastUtil.showToast(this, R.string.c_photo_album_failed);
                }
            }
        } else if (resultCode == RESULT_OK && requestCode == REQUEST_CODE_SELECT_LOCATE) {
            // ??????????????????
            latitude = data.getDoubleExtra(AppConstant.EXTRA_LATITUDE, 0);
            longitude = data.getDoubleExtra(AppConstant.EXTRA_LONGITUDE, 0);
            address = data.getStringExtra(AppConstant.EXTRA_ADDRESS);
            if (latitude != 0 && longitude != 0 && !TextUtils.isEmpty(address)) {
                Log.e("zq", "??????:" + latitude + "   ?????????" + longitude + "   ?????????" + address);
                mTVLocation.setText(address);
            } else {
                ToastUtil.showToast(mContext, getString(R.string.loc_startlocnotice));
            }
        } else if (resultCode == RESULT_OK && requestCode == REQUEST_CODE_SELECT_TYPE) {
            // ??????????????????
            int mOldVisible = visible;
            visible = data.getIntExtra("THIS_CIRCLE_TYPE", 1);
            // ?????????????????????????????????????????????????????????????????????
            if (mOldVisible != visible
                    || visible == 3 || visible == 4) {
                // ???????????????????????? 3/4 ???????????????????????????????????????????????????????????????
                atlookPeople = "";
                mTVAt.setText("");
            }
            if (visible == 1) {
                mTVSee.setText(R.string.publics);
            } else if (visible == 2) {
                mTVSee.setText(R.string.privates);
                if (!TextUtils.isEmpty(atlookPeople)) {
                    final TipDialog tipDialog = new TipDialog(this);
                    tipDialog.setmConfirmOnClickListener(getString(R.string.tip_private_cannot_notify), new TipDialog.ConfirmOnClickListener() {
                        @Override
                        public void confirm() {
                            tipDialog.dismiss();
                        }
                    });
                    tipDialog.show();
                }
            } else if (visible == 3) {
                lookPeople = data.getStringExtra("THIS_CIRCLE_PERSON");
                String looKenName = data.getStringExtra("THIS_CIRCLE_PERSON_NAME");
                mTVSee.setText(looKenName);
            } else if (visible == 4) {
                lookPeople = data.getStringExtra("THIS_CIRCLE_PERSON");
                String lookName = data.getStringExtra("THIS_CIRCLE_PERSON_NAME");
                mTVSee.setText(getString(R.string.not_allow, lookName));
            }
            str1 = data.getStringExtra("THIS_CIRCLE_PERSON_RECOVER1");
            str2 = data.getStringExtra("THIS_CIRCLE_PERSON_RECOVER2");
            str3 = data.getStringExtra("THIS_CIRCLE_PERSON_RECOVER3");
        } else if (resultCode == RESULT_OK && requestCode == REQUEST_CODE_SELECT_REMIND) {
            // ??????????????????
            atlookPeople = data.getStringExtra("THIS_CIRCLE_REMIND_PERSON");
            String atLookPeopleName = data.getStringExtra("THIS_CIRCLE_REMIND_PERSON_NAME");
            mTVAt.setText(atLookPeopleName);
        }
    }

    // ?????????????????? ??????
    private void photograph(final File file) {
        Log.e("zq", "?????????????????????:" + file.getPath() + "?????????????????????:" + file.length() / 1024 + "KB");
        // ?????????????????????Luban???????????????
        Luban.with(this)
                .load(file)
                .ignoreBy(100)     // ????????????100kb ?????????
                // .putGear(2)     // ?????????????????????????????????
                // .setTargetDir() // ??????????????????????????????
                .setCompressListener(new OnCompressListener() { //????????????
                    @Override
                    public void onStart() {
                        Log.e("zq", "????????????");
                    }

                    @Override
                    public void onSuccess(File file) {
                        Log.e("zq", "????????????????????????????????????:" + file.getPath() + "?????????????????????:" + file.length() / 1024 + "KB");
                        mPhotoList.add(file.getPath());
                        postArticleImgAdapter.notifyDataSetChanged();
                    }

                    @Override
                    public void onError(Throwable e) {
                        Log.e("zq", "????????????,????????????");
                        mPhotoList.add(file.getPath());
                        postArticleImgAdapter.notifyDataSetChanged();
                    }
                }).launch();// ????????????
    }

    // ?????????????????? ??????
    private void album(ArrayList<String> stringArrayListExtra, boolean isOriginal) {
        if (isOriginal) {// ????????????????????????
            Log.e("zq", "????????????????????????????????????????????????");
            for (int i = 0; i < stringArrayListExtra.size(); i++) {
                mPhotoList.add(stringArrayListExtra.get(i));
                postArticleImgAdapter.notifyDataSetChanged();
            }
            return;
        }

        List<String> list = new ArrayList<>();
        for (int i = 0; i < stringArrayListExtra.size(); i++) {
            // Luban????????????????????????????????????????????????????????????????????????
            // ???????????????????????????
            // todo luban????????????.gif???????????????????????????.gif??????glide??????????????????gifDrawable????????????????????????,gif???????????????
            List<String> lubanSupportFormatList = Arrays.asList("jpg", "jpeg", "png", "webp");
            boolean support = false;
            for (int j = 0; j < lubanSupportFormatList.size(); j++) {
                if (stringArrayListExtra.get(i).endsWith(lubanSupportFormatList.get(j))) {
                    support = true;
                    break;
                }
            }
            if (!support) {
                list.add(stringArrayListExtra.get(i));
            }
        }

        if (list.size() > 0) {
            for (String s : list) {// ?????????????????????????????????
                mPhotoList.add(s);
                postArticleImgAdapter.notifyDataSetChanged();

            }
        }

        // ???????????????????????????
        stringArrayListExtra.removeAll(mPhotoList);

        Luban.with(this)
                .load(stringArrayListExtra)
                .ignoreBy(100)// ????????????100kb ?????????
                .setCompressListener(new OnCompressListener() {
                    @Override
                    public void onStart() {

                    }

                    @Override
                    public void onSuccess(File file) {
                        mPhotoList.add(file.getPath());
                        postArticleImgAdapter.notifyDataSetChanged();

                    }

                    @Override
                    public void onError(Throwable e) {

                    }
                }).launch();// ????????????
    }

    // ??????????????????
    public void sendShuoshuo() {
        if (TextUtils.isEmpty(mTextEdit.getText().toString().trim()) && mPhotoList.size() == 0) {
            DialogHelper.tip(mContext, getString(R.string.leave_select_image_or_edit_text));
            return;
        }
        Map<String, String> params = new HashMap<>();
        params.put("access_token", coreManager.getSelfStatus().accessToken);
        // ???????????????1=???????????????2=???????????????3=???????????????4=???????????????
        if (TextUtils.isEmpty(mImageData)) {
            params.put("type", "1");
        } else {
            params.put("type", "2");
        }
        // ???????????????1??????????????????2??????????????????3??????????????????
        params.put("flag", "3");

        // ?????????????????????1=?????????2=?????????3=???????????????????????????4=????????????
        params.put("visible", String.valueOf(visible));
        if (visible == 3) {
            // ????????????
            params.put("userLook", lookPeople);
        } else if (visible == 4) {
            // ????????????
            params.put("userNotLook", lookPeople);
        }
        // ????????????
        if (!TextUtils.isEmpty(atlookPeople)) {
            params.put("userRemindLook", atlookPeople);
        }

        // ????????????
        params.put("text", SendTextFilter.filter(mTextEdit.getText().toString()));
        if (!TextUtils.isEmpty(mImageData)) {
            // ??????
            params.put("images", mImageData);
        }

        params.put("isAllowComment", isBoolBan ? String.valueOf(1) : String.valueOf(0));
        /**
         * ????????????
         */
        if (!TextUtils.isEmpty(address)) {
            // ??????
            params.put("latitude", String.valueOf(latitude));
            // ??????
            params.put("longitude", String.valueOf(longitude));
            // ??????
            params.put("location", address);
        }

        // ?????????????????????????????????????????????????????????????????????????????????
        Area area = Area.getDefaultCity();
        if (area != null) {
            // ??????id
            params.put("cityId", String.valueOf(area.getId()));
        } else {
            params.put("cityId", "0");
        }

        /**
         * ????????????
         */
        // ????????????
        params.put("model", DeviceInfoUtil.getModel());
        // ???????????????????????????
        params.put("osVersion", DeviceInfoUtil.getOsVersion());
        if (!TextUtils.isEmpty(DeviceInfoUtil.getDeviceId(mContext))) {
            // ???????????????
            params.put("serialNumber", DeviceInfoUtil.getDeviceId(mContext));
        }

        DialogHelper.showDefaulteMessageProgressDialog(this);

        HttpUtils.post().url(coreManager.getConfig().MSG_ADD_URL)
                .params(params)
                .build()
                .execute(new BaseCallback<String>(String.class) {

                    @Override
                    public void onResponse(ObjectResult<String> result) {
                        DialogHelper.dismissProgressDialog();
                        if (com.xuan.xuanhttplibrary.okhttp.result.Result.checkSuccess(mContext, result)) {
                            Intent intent = new Intent();
                            intent.putExtra(AppConstant.EXTRA_MSG_ID, result.getData());
                            setResult(RESULT_OK, intent);
                            finish();
                        }
                    }

                    @Override
                    public void onError(Call call, Exception e) {
                        DialogHelper.dismissProgressDialog();
                        ToastUtil.showErrorNet(SendShuoshuoActivity.this);
                    }
                });
    }

    interface DragListener {
        /**
         * ??????????????? item?????????????????????????????????????????????
         *
         * @param delete
         */
        void deleteState(boolean delete);

        /**
         * ?????????????????????
         *
         * @param start
         */
        void dragState(boolean start);

        /**
         * ????????????item?????????????????????item???????????????????????????
         */
        void clearView();
    }

    public static class MyCallBack extends ItemTouchHelper.Callback {

        private int dragFlags;
        private int swipeFlags;
        private View removeView;
        private PostArticleImgAdapter adapter;
        private List<String> images;//????????????????????????
        private List<String> originImages;//?????????????????????????????????????????????????????????????????????????????????????????????????????????
        private boolean up;//?????????????????????
        private DragListener dragListener;

        public MyCallBack(View tv, PostArticleImgAdapter adapter, List<String> images, List<String> originImages) {
            removeView = tv;
            this.adapter = adapter;
            this.images = images;
            this.originImages = originImages;
        }

        /**
         * ??????item??????????????????????????????????????????????????????????????????????????????
         *
         * @param recyclerView
         * @param viewHolder
         * @return
         */
        @Override
        public int getMovementFlags(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder) {
            //?????? recyclerView????????????????????????
            if (recyclerView.getLayoutManager() instanceof StaggeredGridLayoutManager) {//????????????????????????
                dragFlags = ItemTouchHelper.UP | ItemTouchHelper.DOWN | ItemTouchHelper.LEFT | ItemTouchHelper.RIGHT;
                swipeFlags = 0;//0??????????????????
            }
            return makeMovementFlags(dragFlags, swipeFlags);
        }

        /**
         * ????????????item????????????????????????????????????item??????????????????????????????
         *
         * @param recyclerView
         * @param viewHolder
         * @param target
         * @return
         */
        @Override
        public boolean onMove(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder, RecyclerView.ViewHolder target) {
            int fromPosition = viewHolder.getAdapterPosition();//??????item?????????position
            int toPosition = target.getAdapterPosition();//????????????position
            if (toPosition == images.size() || images.size() == fromPosition) {
                return true;
            }
            if (fromPosition < toPosition) {
                for (int i = fromPosition; i < toPosition; i++) {
                    Collections.swap(images, i, i + 1);
                }
            } else {
                for (int i = fromPosition; i > toPosition; i--) {
                    Collections.swap(images, i, i - 1);
                }
            }
            adapter.notifyItemMoved(fromPosition, toPosition);
            return true;
        }

        /**
         * ??????????????????????????????
         *
         * @return
         */
        @Override
        public boolean isLongPressDragEnabled() {
            return false;
        }

        /**
         * @param viewHolder
         * @param direction
         */
        @Override
        public void onSwiped(RecyclerView.ViewHolder viewHolder, int direction) {

        }

        /**
         * ????????????item?????????????????????item???????????????????????????
         *
         * @param recyclerView
         * @param viewHolder
         */
        @Override
        public void clearView(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder) {
            super.clearView(recyclerView, viewHolder);
            adapter.notifyDataSetChanged();
            initData();
            if (dragListener != null) {
                dragListener.clearView();
            }
        }

        /**
         * ??????
         */
        private void initData() {
            if (dragListener != null) {
                dragListener.deleteState(false);
                dragListener.dragState(false);
            }
            up = false;
        }

        /**
         * ??????????????????????????????
         *
         * @param c
         * @param recyclerView
         * @param viewHolder
         * @param dX
         * @param dY
         * @param actionState
         * @param isCurrentlyActive
         */
        @Override
        public void onChildDraw(Canvas c, RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder, float dX, float dY, int actionState, boolean isCurrentlyActive) {
            if (null == dragListener) {
                return;
            }
            int[] location = new int[2];
            viewHolder.itemView.getLocationInWindow(location); //???????????????????????????????????????
            if (location[1] + viewHolder.itemView.getHeight() > removeView.getTop()) {//???????????????
                dragListener.deleteState(true);
                if (up) {//??????????????????????????????item
                    viewHolder.itemView.setVisibility(View.INVISIBLE);//??????????????????????????????????????????????????????viewHolder???????????????????????????????????????remove??????viewHolder???????????????????????????viewHolder??????
                    images.remove(viewHolder.getAdapterPosition());
                    adapter.notifyItemRemoved(viewHolder.getAdapterPosition());
                    initData();
                    return;
                }
            } else {//??????????????????
                if (View.INVISIBLE == viewHolder.itemView.getVisibility()) {//??????viewHolder????????????????????????????????????????????????????????????
                    dragListener.dragState(false);
                }
                dragListener.deleteState(false);
            }
            super.onChildDraw(c, recyclerView, viewHolder, dX, dY, actionState, isCurrentlyActive);
        }

        /**
         * ???????????????item??????????????????????????????????????????
         *
         * @param viewHolder
         * @param actionState
         */
        @Override
        public void onSelectedChanged(RecyclerView.ViewHolder viewHolder, int actionState) {
            if (ItemTouchHelper.ACTION_STATE_DRAG == actionState && dragListener != null) {
                dragListener.dragState(true);
            }
            super.onSelectedChanged(viewHolder, actionState);
        }

        /**
         * ?????????????????????ViewHolder????????????????????????????????????????????????
         *
         * @param recyclerView
         * @param animationType
         * @param animateDx
         * @param animateDy
         * @return
         */
        @Override
        public long getAnimationDuration(RecyclerView recyclerView, int animationType, float animateDx, float animateDy) {
            //????????????
            up = true;
            return super.getAnimationDuration(recyclerView, animationType, animateDx, animateDy);
        }

        void setDragListener(DragListener dragListener) {
            this.dragListener = dragListener;
        }

    }

    private class UploadPhoto extends AsyncTask<Void, Integer, Integer> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            DialogHelper.showDefaulteMessageProgressDialog(SendShuoshuoActivity.this);
        }

        /**
         * ?????????????????? <br/>
         * return 1 Token???????????????????????? <br/>
         * return 2 ????????????<br/>
         * return 3 ????????????<br/>
         */
        @Override
        protected Integer doInBackground(Void... params) {
            if (!LoginHelper.isTokenValidation()) {
                return 1;
            }
            Map<String, String> mapParams = new HashMap<>();
            mapParams.put("access_token", coreManager.getSelfStatus().accessToken);
            mapParams.put("userId", coreManager.getSelf().getUserId() + "");
            mapParams.put("validTime", "-1");// ???????????????

            String result = new UploadService().uploadFile(coreManager.getConfig().UPLOAD_URL, mapParams, mPhotoList);
            if (TextUtils.isEmpty(result)) {
                return 2;
            }

            UploadFileResult recordResult = JSON.parseObject(result, UploadFileResult.class);
            boolean success = Result.defaultParser(SendShuoshuoActivity.this, recordResult, true);
            if (success) {
                if (recordResult.getSuccess() != recordResult.getTotal()) {
                    // ???????????????????????????
                    return 2;
                }
                if (recordResult.getData() != null) {
                    UploadFileResult.Data data = recordResult.getData();
                    if (data.getImages() != null && data.getImages().size() > 0) {
                        mImageData = JSON.toJSONString(data.getImages(), UploadFileResult.sImagesFilter);
                    } else {
                        return 2;
                    }
                    return 3;
                } else {
                    // ??????????????????????????????
                    return 2;
                }
            } else {
                return 2;
            }
        }

        @Override
        protected void onPostExecute(Integer result) {
            super.onPostExecute(result);
            if (result == 1) {
                DialogHelper.dismissProgressDialog();
                startActivity(new Intent(SendShuoshuoActivity.this, LoginHistoryActivity.class));
            } else if (result == 2) {
                DialogHelper.dismissProgressDialog();
                ToastUtil.showToast(SendShuoshuoActivity.this, getString(R.string.upload_failed));
            } else {
                sendShuoshuo();
            }
        }
    }

    class PostArticleImgAdapter extends RecyclerView.Adapter<PostArticleImgAdapter.MyViewHolder> {
        private final LayoutInflater mLayoutInflater;
        private final Context mContext;
        private List<String> mDatas;

        public PostArticleImgAdapter(Context context, List<String> datas) {
            this.mDatas = datas;
            this.mContext = context;
            this.mLayoutInflater = LayoutInflater.from(context);
        }

        @Override
        public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new MyViewHolder(mLayoutInflater.inflate(R.layout.item_post_activity, parent, false));
        }

        @Override
        public void onBindViewHolder(final MyViewHolder holder, final int position) {
            if (getItemViewType(position) == 0) { // ???????????????
                holder.squareCenterFrameLayout.setVisibility(View.GONE);
                ImageLoadHelper.showImageWithSizeError(
                        mContext,
                        mDatas.get(position),
                        R.drawable.pic_error,
                        150, 150,
                        holder.imageView
                );
            } else {
                holder.squareCenterFrameLayout.setVisibility(View.VISIBLE);
            }
        }

        @Override
        public int getItemCount() {
            if (mDatas.size() >= 9) {
                return 9;
            }
            return mDatas.size() + 1;
        }

        @Override
        public int getItemViewType(int position) {
            if (mDatas.size() == 0) {
                // View Type 1???????????????????????????
                return 1;
            } else if (mDatas.size() < 9) {
                if (position < mDatas.size()) {
                    // View Type 0???????????????ImageView??????
                    return 0;
                } else {
                    return 1;
                }
            } else {
                return 0;
            }
        }

        class MyViewHolder extends RecyclerView.ViewHolder {
            ImageView imageView;
            SquareCenterFrameLayout squareCenterFrameLayout;

            MyViewHolder(View itemView) {
                super(itemView);
                squareCenterFrameLayout = itemView.findViewById(R.id.add_sc);
                imageView = itemView.findViewById(R.id.sdv);
            }
        }
    }

    public abstract class OnRecyclerItemClickListener implements RecyclerView.OnItemTouchListener {
        private GestureDetectorCompat mGestureDetector;
        private RecyclerView recyclerView;

        public OnRecyclerItemClickListener(RecyclerView recyclerView) {
            this.recyclerView = recyclerView;
            mGestureDetector = new GestureDetectorCompat(recyclerView.getContext(), new ItemTouchHelperGestureListener());
        }

        @Override
        public boolean onInterceptTouchEvent(RecyclerView rv, MotionEvent e) {
            if (mGestureDetector.onTouchEvent(e)) {
                return true;
            }
            return false;
        }

        @Override
        public void onTouchEvent(RecyclerView rv, MotionEvent e) {

        }

        @Override
        public void onRequestDisallowInterceptTouchEvent(boolean disallowIntercept) {
        }

        public abstract void onItemClick(RecyclerView.ViewHolder vh);

        public abstract void onItemLongClick(RecyclerView.ViewHolder vh);

        private class ItemTouchHelperGestureListener extends GestureDetector.SimpleOnGestureListener {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                View child = recyclerView.findChildViewUnder(e.getX(), e.getY());
                if (child != null) {
                    RecyclerView.ViewHolder vh = recyclerView.getChildViewHolder(child);
                    onItemClick(vh);
                    return true;
                }
                return false;
            }

            @Override
            public void onLongPress(MotionEvent e) {
                View child = recyclerView.findChildViewUnder(e.getX(), e.getY());
                if (child != null) {
                    RecyclerView.ViewHolder vh = recyclerView.getChildViewHolder(child);
                    onItemLongClick(vh);
                }
            }
        }
    }
}
