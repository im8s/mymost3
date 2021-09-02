#pragma once

#include "corelib_global.h"

#include "ToolFunc.h"

#include <qglobal.h>
#include <QString>
#include <QMap>
#include <QVector>
#include <QList>
#include <QDateTime>
#include <QMetaType>


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tPlayer
{
	QString		pid;
	QString		strName;
	int			type;

	tPlayer()
	{
		type = -1;
	}
	~tPlayer()
	{

	}
	tPlayer(const tPlayer& other)
	{
		tPlayer::operator = (other);
	}
	const tPlayer& operator = (const tPlayer& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strName = other.strName;
			type = other.type;
		}

		return (*this);
	}
};

Q_DECLARE_METATYPE(tPlayer);

typedef QMap< QString, tPlayer* >	tPlayerMap;
typedef QMap< QString, tPlayer >	tPlayerRefMap;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

enum RobotState
{
	RS_idle = 0,
	RS_init,
	RS_connecting,
	RS_connected,
	RS_logining,
	RS_logined,
	RS_beting,
	RS_beted,
	RS_disconnected,
};

static QString gstrs[] = 
{
	ZN_STR("空闲"),
	ZN_STR("初始化"),
	ZN_STR("正在连接"),
	ZN_STR("连接成功"),
	ZN_STR("正在登录"),
	ZN_STR("登录成功"),
	ZN_STR("正在投注"),
	ZN_STR("投注完毕"),
	ZN_STR("连接断开"),
};

struct CORELIB_EXPORT tRobot
{
	QString		pid;
	QString		strUser;
	QString		strPass;

	QString		strBet;

	RobotState	rs;

	tRobot()
	{
		rs = RS_idle;
	}
	~tRobot()
	{

	}
	tRobot(const tRobot& other)
	{
		tRobot::operator = (other);
	}
	const tRobot& operator = (const tRobot& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strUser = other.strUser;
			strPass = other.strPass;

			strBet = other.strBet;

			rs = other.rs;
		}

		return (*this);
	}

	QString getRSString()
	{
		return gstrs[rs];
	}
	const QString getRSString() const
	{
		return gstrs[rs];
	}
};

Q_DECLARE_METATYPE(tRobot);

typedef QMap< QString, tRobot* >	tRobotMap;
typedef QVector< tRobot* >			tRobotVector;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////





