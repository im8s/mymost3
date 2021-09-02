package com.sk.weichat.call;

/**
 * Created by ls on 2017/12/19 0019.
 */

//持有jitsi通话状态的类
public class JitsistateMachine {
    public static boolean isInCalling = false;
    public static String callingOpposite = "";// 当前正在通话的对象

    public static boolean isFloating = false; // 是否处于悬浮窗状态

    public static void reset() {
        isInCalling = false;
        callingOpposite = "";
    }
}
