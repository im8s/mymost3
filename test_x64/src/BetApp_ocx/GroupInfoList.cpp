#include "GroupInfoList.h"
#include "GroupInfo.h"


GroupInfoList::GroupInfoList(QObject *parent)
	: QObject(parent)
{
	
}

GroupInfoList::~GroupInfoList()
{
	//clear();
}

GroupInfoList::GroupInfoList(const GroupInfoList& other)
{
	GroupInfoList::operator = (other);
}

const GroupInfoList& GroupInfoList::operator = (const GroupInfoList& other)
{
	if (&other != this)
	{
		gilist = other.gilist;
	}

	return (*this);
}

void GroupInfoList::append(GroupInfo* p)
{
	gilist.append(p);
}
