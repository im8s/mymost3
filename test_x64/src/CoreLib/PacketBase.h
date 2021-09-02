#pragma once

#include "corelib_global.h"

#include "gdata.h"
#include "pdata.h"

#include <QObject>


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT PacketBase : public QObject
{
	Q_OBJECT

public:
	PacketBase(QObject *parent = nullptr);
	~PacketBase();

	virtual void parsePacket(const QByteArray& ba){}

Q_SIGNALS:
	void playerEnter(const tPlayer& p);
	void playerLeave(const QString& pid);
	void playersClear();

	void playerState(const QString& pid, int type, int code);
	void setPlayerList(const tPlayerRefMap& prColl, int type);

	void dispTalkMsg(const QString& PID, const QString& strMsg);
	void dispSysTalkMsg(const QString& PID, const QString& strMsg);

public Q_SLOTS:

protected:
	bool		m_bQuit = false;
};

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////



