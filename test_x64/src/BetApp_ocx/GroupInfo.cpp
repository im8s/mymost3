#include "GroupInfo.h"


GroupInfo::GroupInfo(QObject *parent)
	: QObject(parent)
{
	type = -1;
}

GroupInfo::~GroupInfo()
{
}

GroupInfo::GroupInfo(const GroupInfo& other)
{
	GroupInfo::operator = (other);
}

const GroupInfo& GroupInfo::operator = (const GroupInfo& other)
{
	if (&other != this)
	{
		gid = other.gid;
		strName = other.strName;
		type = other.type;
	}

	return (*this);
}
