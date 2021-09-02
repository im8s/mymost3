package com.shiku.im.api.controller;

import com.shiku.common.model.PageResult;
import com.shiku.im.api.AbstractController;
import com.shiku.im.friends.entity.FriendsterWebsite;
import com.shiku.im.friends.service.impl.FriendsterWebsiteManagerImpl;
import com.shiku.im.vo.JSONMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/general")
public class GeneralController extends AbstractController {

    @Autowired
    private FriendsterWebsiteManagerImpl friendsterWebsiteManager;
    /**
     * 发现页广告列表
     *
     * @param page
     * @param limit
     * @return
     */
    @RequestMapping(value = "/friendsterWebsiteList")
    public JSONMessage friendsterWebsiteList(@RequestParam(defaultValue = "1") int page,
                                          @RequestParam(defaultValue = "10") Integer limit) {
        PageResult<FriendsterWebsite> result = friendsterWebsiteManager.queryFriendsterWebsiteList(page,
                limit);
        return JSONMessage.success(result);
    }
}
