package com.shiku.im.friends.entity;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

/**
* @Description: TODO(好友分组)
*
* @date 2018年6月7日 
*/
@ApiModel("好友分组")
@Document(value="friendGroup")
public class FriendGroup {
	
	@Id
	@ApiModelProperty("群编号")
	private ObjectId groupId;
	@ApiModelProperty("分组名称")
	private String groupName;//分组名称
	@ApiModelProperty("用户ID")
	private int userId; //用户ID
	@ApiModelProperty("创建时间")
	private long createTime;

	@ApiModelProperty("多个好友的用户Id")
	private List<Integer> userIdList=new ArrayList<Integer>();//好友的用户Id

	public ObjectId getGroupId() {
		return groupId;
	}

	public void setGroupId(ObjectId groupId) {
		this.groupId = groupId;
	}

	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public long getCreateTime() {
		return createTime;
	}

	public void setCreateTime(long createTime) {
		this.createTime = createTime;
	}

	public List<Integer> getUserIdList() {
		return userIdList;
	}

	public void setUserIdList(List<Integer> userIdList) {
		this.userIdList = userIdList;
	}
	
	

}

