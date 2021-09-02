#include "PlayerInfo.h"


PlayerInfo::PlayerInfo(QObject *parent)
	: QObject(parent)
{
	type = -1;
}

PlayerInfo::~PlayerInfo()
{
}

PlayerInfo::PlayerInfo(const PlayerInfo& other)
{
	PlayerInfo::operator = (other);
}

const PlayerInfo& PlayerInfo::operator = (const PlayerInfo& other)
{
	if (&other != this)
	{
		pid = other.pid;
		strName = other.strName;
		type = other.type;
	}

	return (*this);
}
