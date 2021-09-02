#include "ABetRobot.h"

#include "gdata.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include "msg.pb.h"
using namespace pb;

#include <string>
using namespace std;

#include "Packet.h"

#include <QDebug>
#include <QTime>
#include <QCoreApplication>
#include <QThread>


ABetRobot::ABetRobot(QObject *parent)
	: QObject(parent)
{
	m_cnn = new Connection(this);

	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(readyRead()), this, SLOT(dataFromNetwork()));

	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(connected()), this, SLOT(onConnected()));
	QObject::connect(m_cnn->getTcpSocket(), SIGNAL(disconnected()), this, SLOT(onDisconnected()));
}

ABetRobot::~ABetRobot()
{
	m_bQuit = true;

	disconnect();

	delete m_cnn;
}

bool ABetRobot::connectToHost(const QString &hostName, quint16 port, int msecs)
{
	m_strHostName = hostName;
	m_nPort = port;

	return reconnectToHost(msecs);
}

bool ABetRobot::reconnectToHost(int msecs)
{
	m_bQuit = false;
	m_bConnected = false;

	m_cnn->getTcpSocket()->abort();

	m_cnn->getTcpSocket()->connectToHost(m_strHostName, m_nPort);

	return true;
}

void ABetRobot::disconnect()
{
	if (m_bConnected)
	{
		m_cnn->getTcpSocket()->abort();
		m_cnn->getTcpSocket()->close();

		m_bConnected = false;
	}
}

bool ABetRobot::sendMsg(qint32 msgId, const QByteArray& baData)
{
	return m_cnn->sendMsg(msgId, baData);
}

bool ABetRobot::sendMsg(qint32 msgId, const string& str)
{
	return m_cnn->sendMsg(msgId, str);
}

bool ABetRobot::sendMsg(qint32 msgId, const QString& str)
{
	return m_cnn->sendMsg(msgId, str);
}

bool ABetRobot::sendMsg(const QByteArray& ba)
{
	return m_cnn->sendMsg(ba);
}

bool ABetRobot::sendMsg(const string& str)
{
	return m_cnn->sendMsg(str);
}

bool ABetRobot::sendMsg(const QString& str)
{
	return m_cnn->sendMsg(str);
}

bool ABetRobot::doLoginMsg(const QString& strUser, const QString& strPass)
{
	QByteArray ba;
	if (!Packet::packPlayerLoginMsg(ba, 0, strUser, strPass, m_nUserType))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ABetRobot::doLoginMsg()
{
	return doLoginMsg(m_robot.strUser, m_robot.strPass);
}

bool ABetRobot::doPlayerReqMsg(int rtype)
{
	QByteArray ba;
	if (!Packet::packPlayerReqMsg(ba, m_robot.pid.toUtf8(), 0, rtype))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ABetRobot::doTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packTalkMsg(ba, m_robot.pid, 1, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ABetRobot::doSysTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packSysTalkMsg(ba, m_robot.pid, 3, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

void ABetRobot::dataFromNetwork()
{
	int len = m_cnn->getTcpSocket()->bytesAvailable();
	if (len > 0)
	{
		QByteArray ba = m_cnn->getTcpSocket()->readAll();

		BCMGR->parsePacket(ba);
	}
}

void ABetRobot::onConnected()
{
	if (!m_bConnected)
	{
		m_bConnected = true;

		Q_EMIT connectedStateChanged(m_robot.pid, true);
	}
}

void ABetRobot::onDisconnected()
{
	if (!m_bQuit)
	{
		disconnect();

		Q_EMIT connectedStateChanged(m_robot.pid, false);
	}
}

void ABetRobot::slotTalkMsg(const QString& strMsg)
{
	doTalkMsg(strMsg);
}

void ABetRobot::slotSysTalkMsg(const QString& strMsg)
{
	doSysTalkMsg(strMsg);
}


