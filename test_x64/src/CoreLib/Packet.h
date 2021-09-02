#pragma once

#include "corelib_global.h"

#include "PacketBase.h"

#include "DataPacket.h"

#include "msg.pb.h"
using namespace pb;

#include <string>
using namespace std;

//#include <google/protobuf/message.h>
#include <google/protobuf/port_def.inc>
using namespace PROTOBUF_NAMESPACE_ID;

#include <QObject>


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tMsgData
{
	tMsgData()
	{

	}
	~tMsgData()
	{
		delete msg;
	}
	tMsgData(const tMsgData& other)
	{
		tMsgData::operator=(other);
	}
	const tMsgData& operator = (const tMsgData& other)
	{
		if (&other != this)
		{
			dh = other.dh;
			str = other.str;
		}

		return (*this);
	}

	tDataHead	dh;
	string		str;

	Message *	msg = nullptr;
};

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT Packet : public PacketBase
{
	Q_OBJECT

public:
	Packet(QObject *parent = nullptr);
	~Packet();

	void parsePacket(const QByteArray& ba) override;

	static bool pack(QByteArray& baData, const Message& message);
	static Message* unpack(const string& str);
	static Message* unpack(const QByteArray& baData);

	static bool packPlayerLoginMsg(QByteArray& baData, qint32 msgId, const QString& strUser, const QString& strPass, int nUserType);
	static bool packTalkMsg(QByteArray& baData, const QString& pid, qint32 msgId, const QString& strMsg);
	static bool packSysTalkMsg(QByteArray& baData, const QString& pid, qint32 msgId, const QString& strMsg);
	static bool packPlayerReqMsg(QByteArray& baData, const QString& pid, qint32 msgId, int rtype);

protected:
	bool unpackData(QByteArray& ba, tMsgData& msg);

private:
	void dispMessage(const tMsg& msg);

	void processPlayerResMsg(const string& strData);
	void processTalkMsg(const string& str);
	void processSysTalkMsg(const string& strData);
	
Q_SIGNALS:
	/*void setLotteryState(int type, int code);
	void setLotteryServerTime(const tServerTime& st);
	void setLotteryHistory(const tLotteryRefMap& coll);
	void setLotteryNext(const tLottery& lot);
	void setLotteryLatest(const tLottery& lot);*/

public Q_SLOTS:

private:
	QByteArray		m_baData;
};

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////



