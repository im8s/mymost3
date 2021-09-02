#include "ARobot.h"

#include "gdata.h"

#include "RobotApplication.h"
#include "RobotManager.h"

#include "Packet.h"

#include "msg.pb.h"
using namespace pb;

#include <string>
using namespace std;

#include <QDebug>
#include <QTime>
#include <QCoreApplication>
#include <QThread>


ARobot::ARobot(QObject *parent)
	: QObject(parent)
{
	m_robot = new tRobot();

	m_cnn = new Connection();
	{
		QObject::connect(m_cnn->getTcpSocket(), SIGNAL(readyRead()), this, SLOT(dataFromNetwork()));

		QObject::connect(m_cnn->getTcpSocket(), SIGNAL(connected()), this, SLOT(onConnected()));
		QObject::connect(m_cnn->getTcpSocket(), SIGNAL(disconnected()), this, SLOT(onDisconnected()));
	}

	m_pb = new Packet();
	{
		QObject::connect(m_pb, SIGNAL(playerEnter(const tPlayer&)), this, SLOT(playerEnter(const tPlayer&)));
		QObject::connect(m_pb, SIGNAL(playerLeave(const QString&)), this, SLOT(playerLeave(const QString&)));
		QObject::connect(m_pb, SIGNAL(playersClear()), this, SLOT(playersClear()));

		QObject::connect(m_pb, SIGNAL(playerState(const QString&, int, int)), this, SLOT(playerState(const QString&, int, int)));
		QObject::connect(m_pb, SIGNAL(setPlayerList(const tPlayerRefMap&, int)), this, SLOT(setPlayerList(const tPlayerRefMap&, int)));

		QObject::connect(m_pb, SIGNAL(dispTalkMsg(const QString&, const QString&)), this, SLOT(dispTalkMsg(const QString&, const QString&)));
		QObject::connect(m_pb, SIGNAL(dispSysTalkMsg(const QString&, const QString&)), this, SLOT(dispSysTalkMsg(const QString&, const QString&)));
	}
}

ARobot::~ARobot()
{
	m_bQuit = true;

	disconnect();

	delete m_cnn;
	delete m_pb;

	delete m_robot;
}

bool ARobot::doAction(int ind)
{
	bool bRet = false;

	RobotState rs = m_robot->rs;

	if (RS_init == rs)
	{
		reconnectToHost();

		setRobotStatus(RS_connecting);

		bRet = true;
	}
	else if (RS_connected == rs)
	{
#ifdef USE_AUTOLOGIN
#else
		doLoginMsg();

		//setRobotStatus(RS_logining);

		bRet = true;
#endif
	}
	else if (RS_logined == rs)
	{
		setRobotStatus(RS_beting);
	}
	else if (RS_beting == rs)
	{
		doBet(ind);

		//setRobotStatus(RS_beted);

		bRet = true;
	}
	else if (RS_disconnected == rs)
	{
		//setRobotStatus(RS_init);
	}

	return bRet;
}

bool ARobot::connectToHost(const QString &hostName, quint16 port, int msecs)
{
	m_strHostName = hostName;
	m_nPort = port;

	return reconnectToHost(msecs);
}

bool ARobot::reconnectToHost(int msecs)
{
	m_bQuit = false;
	m_bConnected = false;

	m_cnn->getTcpSocket()->abort();
	m_cnn->getTcpSocket()->connectToHost(m_strHostName, m_nPort);

	/*if (m_cnn->getTcpSocket()->waitForConnected())
	{
		m_bConnected = true;

		setRobotStatus(RS_connected);
	}*/

	return true;
}

void ARobot::disconnect()
{
	if (m_bConnected)
	{
		m_cnn->getTcpSocket()->abort();
		m_cnn->getTcpSocket()->close();

		//m_cnn->getTcpSocket()->waitForDisconnected();

		m_bConnected = false;

		//setRobotStatus(RS_disconnected);

		qDebug() << "ARobot::disconnect: PID = " << m_robot->pid;
	}
}

bool ARobot::sendMsg(qint32 msgId, const QByteArray& baData)
{
	return m_cnn->sendMsg(msgId, baData);
}

bool ARobot::sendMsg(qint32 msgId, const string& str)
{
	return m_cnn->sendMsg(msgId, str);
}

bool ARobot::sendMsg(qint32 msgId, const QString& str)
{
	return m_cnn->sendMsg(msgId, str);
}

bool ARobot::sendMsg(const QByteArray& ba)
{
	return m_cnn->sendMsg(ba);
}

bool ARobot::sendMsg(const string& str)
{
	return m_cnn->sendMsg(str);
}

bool ARobot::sendMsg(const QString& str)
{
	return m_cnn->sendMsg(str);
}

bool ARobot::doLoginMsg(const QString& strUser, const QString& strPass)
{
	QByteArray ba;
	if (!Packet::packPlayerLoginMsg(ba, 0, strUser, strPass, m_nUserType))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ARobot::doLoginMsg()
{
	return doLoginMsg(m_robot->strUser, m_robot->strPass);
}

bool ARobot::doPlayerReqMsg(int rtype)
{
	QByteArray ba;
	if (!Packet::packPlayerReqMsg(ba, m_robot->pid.toUtf8(), 0, rtype))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ARobot::doTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packTalkMsg(ba, m_robot->pid, 1, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

bool ARobot::doSysTalkMsg(const QString& strMsg)
{
	QByteArray ba;
	if (!Packet::packSysTalkMsg(ba, m_robot->pid, 3, strMsg.toUtf8()))
		return false;

	if (!m_cnn->sendMsg(ba))
		return false;

	return true;
}

void ARobot::dataFromNetwork()
{
	int len = m_cnn->getTcpSocket()->bytesAvailable();
	if (len > 0)
	{
		QByteArray ba = m_cnn->getTcpSocket()->readAll();

		parsePacket(ba);
	}
}

void ARobot::onConnected()
{
	if (!m_bConnected)
	{
		m_bConnected = true;

		Q_EMIT connectedStateChanged(m_robot->pid, true);

#ifdef USE_AUTOLOGIN
		setRobotStatus(RS_logining); 
		doLoginMsg();
#else
		setRobotStatus(RS_connected);
#endif
	}
}

void ARobot::onDisconnected()
{
	if (!m_bQuit)
	{
		disconnect();

		Q_EMIT connectedStateChanged(m_robot->pid, false);

		setRobotStatus(RS_disconnected);
	}
}

void ARobot::parsePacket(const QByteArray& ba)
{
	m_pb->parsePacket(ba);
}

bool ARobot::doBet(int ind)
{
	static const QString strlstBetStrs[] = { 
		ZN_STR("草"),
		ZN_STR("."),
		ZN_STR("艹"),
		ZN_STR("操"),
		ZN_STR("极大"),
		ZN_STR("极小"),
		ZN_STR("豹子"),
		ZN_STR("对子"),
		ZN_STR("顺子"),
		ZN_STR("大单"),
		ZN_STR("大双"),
		ZN_STR("小单"),
		ZN_STR("小双"),
		ZN_STR("大"),
		ZN_STR("小"),
		ZN_STR("单"),
		ZN_STR("双"),
	};

	{
		int nBetCnt = sizeof(strlstBetStrs) / sizeof(strlstBetStrs[0]);

		QString strBet;

#if 1
		//int nBetTotalNum = (qrand() % 9) + 1;
		int nBetNum = (qrand() % 4) + 1;

		//while (nBetTotalNum > 0)
		{
			for (int k = 0; k < nBetNum; ++k)
			{
				QString strMsg;
				{
					int nBetInd = (qrand() % nBetCnt);
					int nAmount = (qrand() % 500) + 50;

					if (nBetInd >= 0 && nBetInd < 4)
					{
						int nDig = (qrand() % 28);

						strMsg = QString::number(nDig) + strlstBetStrs[nBetInd] + QString::number(nAmount);
					}
					else
					{
						strMsg = strlstBetStrs[nBetInd] + QString::number(nAmount);
					}
				}

				if (!strBet.isEmpty())
					strBet += ",";

				strBet += strMsg;
			}

			m_robot->strBet = strBet;

			QString strAllBetStr = strBet.replace(",", " ");
			doTalkMsg(strAllBetStr);

			//--nBetTotalNum;

			qDebug() << ZN_STR("[%1] [PID: %2] ARobot::doBet strAllBetStr = %3").arg(ind).arg(m_robot->pid).arg(strAllBetStr);
		}

		//setRobotStatus(RS_beted);
#else
		if(0 == m_nBetNum)
			m_nBetNum = (qrand() % 9) + 1;

		if (m_nCurNum < m_nBetNum)
		{
			QString strMsg;
			{
				int nBetInd = (qrand() % nBetCnt);
				int nAmount = (qrand() % 500) + 50;

				if (nBetInd >= 0 && nBetInd < 4)
				{
					int nDig = (qrand() % 28);

					strMsg = QString::number(nDig) + strlstBetStrs[nBetInd] + QString::number(nAmount);
				}
				else
				{
					strMsg = strlstBetStrs[nBetInd] + QString::number(nAmount);
				}
			}

			doTalkMsg(strMsg);

			QThread::msleep(10);

			if (!strBet.isEmpty())
				strBet += ",";

			strBet += strMsg;

			if (!m_robot.strBet.isEmpty())
				m_robot.strBet += ",";
			m_robot.strBet += strBet;

			++m_nCurNum;
		}
		else
		{
			m_nCurNum = 0;
			m_nBetNum = 0;

			setRobotStatus(RS_beted);
		}
#endif
	}

	return true;
}

void ARobot::setRobotStatus(RobotState rs)
{
	if (m_robot->rs != rs)
	{
		m_robot->rs = rs;

		m_bStatusChanged = true;
	}
}

void ARobot::playerEnter(const tPlayer& p)
{
	/*if (!isExistPScoreInfo(p.pid))
	{
		tPScoreInfo* psi = new tPScoreInfo();
		{
			psi->pid = p.pid;
			psi->strName = p.strName;
			psi->nType = p.type;
#ifdef _DEBUG
			psi->fTotalScore = 100000;
#else
			psi->fTotalScore = 100000;
#endif
		}

		appendPScoreInfo(psi);

		refreshModelForPSCoreInfo();
	}*/
}

void ARobot::playerLeave(const QString& pid)
{
	/*removePScoreInfo(pid);

	refreshModelForPSCoreInfo();*/
}

void ARobot::playersClear()
{
	/*clearAllPScoreInfo();

	refreshModelForPSCoreInfo();*/
}

void ARobot::playerState(const QString& pid, int type, int code)
{
	if (0 == type)
	{
		if (0 == code)
		{
			setPId(pid);

			//m_sm->doAction(GA_LoginingDone);

			//QString strMsg = ZN_STR("当前用户: %1").arg(pid);
			//Q_EMIT statusMsgHint(0, strMsg);

			setRobotStatus(RS_logined);
		}
	}
}

void ARobot::setPlayerList(const tPlayerRefMap& prColl, int type)
{
	/*for (tPlayerRefMap::ConstIterator cit = prColl.cbegin();
		cit != prColl.cend(); ++cit)
	{
		const tPlayer& p = cit.value();

		if (!isExistPScoreInfo(p.pid))
		{
			tPScoreInfo* psi = new tPScoreInfo();
			{
				psi->pid = p.pid;
				psi->strName = p.strName;
				psi->nType = p.type;
				psi->fTotalScore = 100000;
			}

			appendPScoreInfo(psi);
		}
	}

	refreshModelForPSCoreInfo();

	m_sm->doAction(GS_fetchplayerlistDone);*/
}

void ARobot::dispTalkMsg(const QString& pid, const QString& strMsg)
{
	//Q_EMIT dispTalkMsg(pid, pid, strMsg, 0);
}

void ARobot::dispSysTalkMsg(const QString& pid, const QString& strMsg)
{
	//Q_EMIT dispTalkMsg(pid, pid, strMsg, 1);

	{
		/*QString strBetStr = strMsg.simplified();
		if (strBetStr.indexOf(ZN_STR("开盘开始下注")) != -1)
		{
			setRobotStatus(RS_beting);
			m_robot->strBet = "";
		}
		else if (strBetStr.indexOf(ZN_STR("封盘停止下注")) != -1)
		{
			setRobotStatus(RS_beted);
		}*/
	}
}

void ARobot::connectedStateChanged(const QString& pid, bool bConnected)
{
	/*if (bConnected)
	{
		m_sm->doAction(GA_ConnectingDone);
	}
	else
	{
		m_sm->doAction(GA_DisconnectingDone);
	}*/
}

void ARobot::stateChanged(quint32 msgId, qint32 code)
{
	/*if (0 == msgId && 0 == code)
	{
		m_sm->doAction(GA_LoginedDone);
	}*/
}
