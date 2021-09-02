package com.gunan.im.wxapi;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.sk.weichat.R;
import com.sk.weichat.ui.base.BaseActivity;
import com.sk.weichat.util.Constants;
import com.sk.weichat.view.TipDialog;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

public class WXPayEntryActivity extends BaseActivity implements IWXAPIEventHandler {
    private IWXAPI api;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.account_pay_result);

        api = WXAPIFactory.createWXAPI(WXPayEntryActivity.this, Constants.VX_APP_ID, false);
        api.handleIntent(getIntent(), this);

        initActionBar();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        api.handleIntent(intent, this);
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
        tvTitle.setText(R.string.recharge_result);
    }

    @Override
    public void onReq(BaseReq req) {
    }

    @Override
    public void onResp(BaseResp resp) {
        if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
            TipDialog tipDialog = new TipDialog(this);
            String tipStr;
            if (resp.errCode == 0) {
                tipStr = getString(R.string.recharge_success);
            } else if (resp.errCode == -2) {
                tipStr = getString(R.string.recharge_cancel);
            } else {
                tipStr = getString(R.string.recharge_failed);
            }
            tipDialog.setmConfirmOnClickListener(tipStr, new TipDialog.ConfirmOnClickListener() {
                @Override
                public void confirm() {
                    finish();
                }
            });
            tipDialog.show();
        }
    }

}