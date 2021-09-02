package com.sk.weichat.db.dao.login;

import java.util.ArrayList;
import java.util.List;


/**
 * Created by Administrator on 2018/4/27 0027.
 */

public class MachineDao {
    private static MachineDao instance = null;
    // 当前在线设备
    public List<String> lineDevice = new ArrayList<>();

    private MachineDao() {
    }

    public static MachineDao getInstance() {
        if (instance == null) {
            synchronized (MachineDao.class) {
                if (instance == null) {
                    instance = new MachineDao();
                }
            }
        }
        return instance;
    }

    // 获取设备在线状态
    public boolean getMachineOnLineStatus(String deviceName) {
        for (int i = 0; i < lineDevice.size(); i++) {
            if (lineDevice.get(i).equals(deviceName)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 修改登陆状态
     *
     * @param resources
     */
    public void changeDevice(String resources) {
        resetMachineStatus();
        String[] devices = resources.split(",");
        for (int i = 0; i < devices.length; i++) {
            lineDevice.add(devices[i]);
        }
    }

    public List<String> getLineDevice() {
        return lineDevice;
    }

    public int getLineDeviceCount() {
        return lineDevice.size();
    }

    public void resetMachineStatus() {
        lineDevice.clear();
    }

}

