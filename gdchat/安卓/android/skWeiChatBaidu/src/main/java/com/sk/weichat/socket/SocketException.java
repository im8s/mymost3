package com.sk.weichat.socket;

/**
 * create by zq
 * 2019.1.17
 */
public class SocketException {
    public static final String SELECTOR_OPEN_EXCEPTION = "selector_open_exception";
    public static final String SELECTOR_SELECT_EXCEPTION = "selector_select_exception";
    public static final String SELECTION_KEY_INVALID = "selection_key_invalid";

    public static final String SOCKET_CHANNEL_OPEN_EXCEPTION = "socket_channel_open_exception";

    public static final String FINISH_CONNECT_EXCEPTION = "finish_connect_exception";

    public static final String LOGIN_MESSAGE_SEND_FAILED_EXCEPTION = "login_message_send_failed_exception";
    public static final String LOGIN_FAILED_EXCEPTION = "login_failed_exception";
    public static final String LOGIN_CONFLICT_EXCEPTION = "login_conflict_exception";

    public static final String SOCKET_PING_FAILED = "socket_ping_failed";
}
