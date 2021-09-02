package com.sk.weichat.ui.base;

import android.content.res.Configuration;
import android.content.res.Resources;

/**
 * 让App字体不受系统设置字体的影响
 *
 * @author Dean Tao
 */
public abstract class DefaultResourceActivity extends SwipeBackActivity {
    /* System default config */
    private static Configuration config = new Configuration();

    @Override
    public Resources getResources() {
        Resources res = super.getResources();
        res.updateConfiguration(config, res.getDisplayMetrics());
        return res;
    }
}
