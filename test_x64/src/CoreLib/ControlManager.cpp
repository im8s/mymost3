#include "ControlManager.h"

#include "gdata.h"

#include "Packet.h"

#include "msg.pb.h"
using namespace pb;

#include <string>
using namespace std;

#include <QDebug>
#include <QTime>
#include <QCoreApplication>


ControlManager::ControlManager(QObject *parent)
	: QObject(parent)
{
	m_cnn = new Connection();

	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(readyRead()), this, SLOT(dataFromNetwork()));

	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(connected()), this, SLOT(onConnected()));
	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(disconnected()), this, SLOT(onDisconnected()));
}

ControlManager::~ControlManager()
{
	m_bQuit = true;

	disconnect();

	delete m_cnn;
}

bool ControlManager::connectToHost(const QString &hostName, quint16 port, int msecs)
{
	m_strHostName = hostName;
	m_nPort = port;

	return reconnectToHost(msecs);
}

bool ControlManager::reconnectToHost(int msecs)
{
	m_bQuit = false;
	m_bConnected = false;

	m_cnn->getTcpSocket()->abort();
	m_cnn->getTcpSocket()->connectToHost(m_strHostName, m_nPort);

	QTime tm;
	tm.start();
	while (!m_bQuit)
	{
		//QCoreApplication::processEvents();

		if (m_bConnected)
			return true;

		if (tm.elapsed() > msecs)
			break;
	}

	return false;
}

void ControlManager::disconnect()
{
	m_cnn->getTcpSocket()->abort();
	m_cnn->getTcpSocket()->close();

	m_bConnected = false;

	m_strPid.clear();
	m_strName.clear();

	clearAllPlayers();
}

bool ControlManager::doLoginMsg(const QString& strUser, const QString& strPass)
{
	QByteArray ba;
	if (!Packet::packPlayerLoginMsg(ba, 0, strUser, strPass, m_nUserType))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ControlManager::doTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packTalkMsg(ba, m_strPid, 1, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ControlManager::doSysTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packSysTalkMsg(ba, m_strPid, 3, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

void ControlManager::dataFromNetwork()
{
	int len = m_cnn->getTcpSocket()->bytesAvailable();
	if (len > 0)
	{
		QByteArray ba = m_cnn->getTcpSocket()->readAll();

		parsePacket(ba);
	}
}

void ControlManager::onConnected()
{
	m_bConnected = true;

	Q_EMIT connectedStateChanged(true);
}

void ControlManager::onDisconnected()
{
	if (!m_bQuit)
	{
		disconnect();

		Q_EMIT connectedStateChanged(false);
	}
}

void ControlManager::parsePacket(const QByteArray& ba)
{
	m_baData += ba;

	while (!m_bQuit)
	{
		DataPacket dp;
		tMsg msg;

		if (dp.unpackData(m_baData, msg))
		{
			dispMessage(msg);
		}
		else
			break;
	}
}

void ControlManager::dispMessage(const tMsg& msg)
{
	//if (99 == msg.dh.id)
	//{
	//	processStateMsg(msg.str);
	//}
	//else if (1 == msg.dh.id)
	//{
	//	processTalkMsg(msg.str);
	//}
	//else if (3 == msg.dh.id)
	//{
	//	processSysTalkMsg(msg.str);
	//}
	//else if (100 == msg.dh.id)
	//{
	//	processChatPlayerMsg(msg.str);
	//}
	//else if (101 == msg.dh.id)
	//{
	//	processPlayerListMsg(msg.str);

	//	//Q_EMIT setGStatus(GS_init);
	//}
	//else if (102 == msg.dh.id)
	//{
	//	Q_EMIT processLotteryResMsg(msg.str);
	//}
}

//void ControlManager::processStateMsg(const string& str)
//{
//	StateMsg msg;
//	msg.ParseFromString(str);
//
//	if (0 == msg.msgid())
//	{
//		Q_EMIT stateChanged(0, msg.code());
//
//		qint32 pid = msg.pid();
//		setPlayerId(pid);
//
//		{
//			QString strMsg = ZN_STR("当前用户: %1 [ID: %2]").arg(m_strName).arg(pid);
//			Q_EMIT statusMsgHint(0, strMsg);
//		}
//	}
//}

//void ControlManager::processTalkMsg(const string& strData)
//{
//	TalkMsg msg;
//	msg.ParseFromString(strData);
//
//	qint32 pid = msg.pid();
//
//	tPlayer p;
//	if (getPlayer(pid, p))
//	{
//		int flag = (pid == m_nPlayerId ? 0 : 1);
//
//		Q_EMIT dispTalkMsg(pid, p.strName, msg.content(), flag);
//	}
//}

//void ControlManager::processSysTalkMsg(const string& strData)
//{
//	SysMsg msg;
//	msg.ParseFromString(strData);
//
//	qint32 pid = msg.pid();
//
//	tPlayer p;
//	if (getPlayer(pid, p))
//	{
//		Q_EMIT dispTalkMsg(pid, p.strName, msg.content(),2);
//	}
//}

//void ControlManager::processChatPlayerMsg(const string& strData)
//{
//	ChatPlayerMsg msg;
//	msg.ParseFromString(strData);
//
//	{
//		tPlayer p;
//		{
//			p.pid = msg.pid();
//			p.strName = msg.name().data();
//			p.type = msg.type();
//		}
//
//		int flag = msg.flag();
//		if (0 == flag)
//		{
//			addPlayer(p);
//		}
//		else if (1 == flag)
//		{
//			removePlayer(p.pid);
//		}
//	}
//}

//void ControlManager::processPlayerListMsg(const string& strData)
//{
//	PlayerListMsg msg;
//	msg.ParseFromString(strData);
//
//	for (int i = 0; i < msg.players_size(); ++i)
//	{
//		const pb::ChatPlayerMsg& cpm = msg.players(i);
//
//		{
//			tPlayer p;
//
//			p.pid = cpm.pid();
//			p.strName = cpm.name().data();
//			p.type = cpm.type();
//
//			addPlayer(p);
//
//			qDebug() << "######### playerlist: pid = " << p.pid << ", name = " << p.strName;
//		}
//	}
//}

void ControlManager::addPlayer(const tPlayer& p)
{
	QMutexLocker locker(&m_playerLock);

	if (!m_playerColl.contains(p.pid))
	{
		tPlayer* pp = new tPlayer(p);

		m_playerColl[p.pid] = pp;

		Q_EMIT playerEnter(p);
	}
}

void ControlManager::removePlayer(const QString& pid)
{
	QMutexLocker locker(&m_playerLock);

	if (m_playerColl.contains(pid))
	{
		m_playerColl.remove(pid);

		Q_EMIT playerLeave(pid);
	}
}

bool ControlManager::getPlayer(const QString& pid, tPlayer& p)
{
	QMutexLocker locker(&m_playerLock);

	if (m_playerColl.contains(pid))
	{
		p = (*m_playerColl[pid]);
		return true;
	}

	return false;
}

void ControlManager::clearAllPlayers()
{
	QMutexLocker locker(&m_playerLock);

	m_playerColl.clear();

	Q_EMIT playersClear();
}

