#include "PlayerInfoList.h"
#include "PlayerInfo.h"


PlayerInfoList::PlayerInfoList(QObject *parent)
	: QObject(parent)
{
	
}

PlayerInfoList::~PlayerInfoList()
{
	//clear();
}

PlayerInfoList::PlayerInfoList(const PlayerInfoList& other)
{
	PlayerInfoList::operator = (other);
}

const PlayerInfoList& PlayerInfoList::operator = (const PlayerInfoList& other)
{
	if (&other != this)
	{
		pilist = other.pilist;
	}

	return (*this);
}

void PlayerInfoList::append(PlayerInfo* p)
{
	pilist.append(p);
}
