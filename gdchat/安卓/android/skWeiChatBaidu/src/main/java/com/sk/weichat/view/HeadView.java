package com.sk.weichat.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.res.TypedArray;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;

import com.makeramen.roundedimageview.RoundedImageView;
import com.sk.weichat.R;
import com.sk.weichat.bean.RoomMember;

/**
 * 单人的头像，
 * 群组是另外的组合头像，
 */
public class HeadView extends RelativeLayout {

    private RoundedImageView ivHead;
    private ImageView ivFrame;
    private View layout;
    private boolean isMessage;

    public HeadView(Context context) {
        super(context);
        init();
    }

    public HeadView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, R.styleable.HeadView, 0, 0);
        isMessage = a.getBoolean(R.styleable.HeadView_isMessage,false );
        init();
    }

    public HeadView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, R.styleable.HeadView, 0, 0);
        isMessage = a.getBoolean(R.styleable.HeadView_isMessage,false );
        init();
    }

    @SuppressWarnings("unused")
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public HeadView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        if(!isMessage){
            layout = View.inflate(getContext(), R.layout.view_head, this);
        }else {
            layout = View.inflate(getContext(), R.layout.message_view_head, this);
        }
        ivHead = layout.findViewById(R.id.ivHead);
        ivFrame = layout.findViewById(R.id.ivFrame);
    }

    public ImageView getHeadImage() {
        return ivHead;
    }

    public void setGroupRole(Integer role) {
        if (role == null) {
            ivFrame.setVisibility(View.GONE);
            return;
        }
        switch (role) {
            case RoomMember.ROLE_OWNER:
                ivFrame.setImageResource(R.mipmap.frame_group_owner);
                ivFrame.setVisibility(View.VISIBLE);
                break;
            case RoomMember.ROLE_MANAGER:
                ivFrame.setImageResource(R.mipmap.frame_group_manager);
                ivFrame.setVisibility(View.VISIBLE);
                break;
            default:
                ivFrame.setVisibility(View.GONE);
        }
    }

    public void setRound(int radius) {
        ivHead.setCornerRadius(radius);
        ivHead.setOval(false);
    }
}
