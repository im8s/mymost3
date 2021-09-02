package com.sk.weichat.ui.other;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.sk.weichat.R;
import com.sk.weichat.bean.User;
import com.sk.weichat.ui.base.BaseActivity;
import com.sk.weichat.ui.map.MapActivity;
import com.sk.weichat.util.TimeUtils;
import com.sk.weichat.util.ToastUtil;

public class MoreInfoActivity extends BaseActivity {
    private TextView birthday_tv;
    private TextView online_tv;
    private RelativeLayout online_rl;

    private RelativeLayout erweima;

    private RelativeLayout look_location_rl;
    private User mUser;
    private Context mContext = MoreInfoActivity.this;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_more_info);
        mUser = (User) getIntent().getParcelableExtra("user");
        initView();
        initActionBar();
    }

    private void initActionBar() {
        getSupportActionBar().hide();
        findViewById(R.id.iv_title_left).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
        TextView tvTitle = (TextView) findViewById(R.id.tv_title_center);
        tvTitle.setText(getResources().getString(R.string.more_info));
    }

    private void initView() {
        birthday_tv = (TextView) findViewById(R.id.birthday_tv);
        online_tv = (TextView) findViewById(R.id.online_tv);
        online_rl = (RelativeLayout) findViewById(R.id.online_rl);
        erweima = (RelativeLayout) findViewById(R.id.erweima);
        look_location_rl = (RelativeLayout) findViewById(R.id.look_location_rl);
        initEvent();
    }

    private void initEvent() {
        birthday_tv.setText(TimeUtils.sk_time_s_long_2_str_for_birthday(mUser.getBirthday()));
        look_location_rl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                double latitude = 0;
                double longitude = 0;
                if (mUser != null && mUser.getLoc() != null) {
                    latitude = mUser.getLoc().getLat();
                    longitude = mUser.getLoc().getLng();
                }
                if (latitude == 0 || longitude == 0) {
                    ToastUtil.showToast(mContext, getString(R.string.this_friend_not_open_position));
                    return;
                }
                Intent intent = new Intent(mContext, MapActivity.class);
                intent.putExtra("latitude", latitude);
                intent.putExtra("longitude", longitude);
                intent.putExtra("address", mUser.getNickName());
                startActivity(intent);
            }
        });

        if (mUser.getShowLastLoginTime() > 0) {
            online_rl.setVisibility(View.VISIBLE);
            online_tv.setText(TimeUtils.getFriendlyTimeDesc(this, mUser.getShowLastLoginTime()));
        } else {
            online_rl.setVisibility(View.GONE);
        }

        erweima.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mUser != null) {
                    Intent intent = new Intent(MoreInfoActivity.this, QRcodeActivity.class);
                    intent.putExtra("isgroup", false);
                    if (!TextUtils.isEmpty(mUser.getAccount())) {
                        intent.putExtra("userid", mUser.getAccount());
                    } else {
                        intent.putExtra("userid", mUser.getUserId());
                    }
                    intent.putExtra("userAvatar", mUser.getUserId());
                    startActivity(intent);
                }
            }
        });
    }

}
