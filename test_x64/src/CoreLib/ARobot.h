#pragma once

#include "corelib_global.h"

#include "Connection.h"

#include <QObject>

//#define USE_AUTOLOGIN	1

class PacketBase;
class CORELIB_EXPORT ARobot : public QObject
{
	Q_OBJECT

public:
	ARobot(QObject *parent = nullptr);
	~ARobot();

	void setParams(const QString &hostName, quint16 port)
	{
		m_strHostName = hostName;
		m_nPort = port;
	}

	bool doAction(int ind);

	bool connectToHost(const QString &hostName, quint16 port, int msecs = 30000);
	bool reconnectToHost(int msecs = 30000);
	void disconnect();

	bool sendMsg(qint32 msgId, const QByteArray& baData);
	bool sendMsg(qint32 msgId, const string& str);
	bool sendMsg(qint32 msgId, const QString& str);

	bool sendMsg(const QByteArray& baData);
	bool sendMsg(const string& str);
	bool sendMsg(const QString& str);

	bool doLoginMsg(const QString& strUser, const QString& strPass);
	bool doLoginMsg();
	bool doPlayerReqMsg(int rtype);
	bool doTalkMsg(const QString& str);
	bool doSysTalkMsg(const QString& str);
	
	Connection* getConnection()
	{
		return m_cnn;
	}
	const Connection* getConnection() const
	{
		return m_cnn;
	}

	void setPId(const QString& pid)
	{
		m_robot->pid = pid;
	}
	QString getPId()
	{
		return m_robot->pid;
	}
	const QString getPId() const
	{
		return m_robot->pid;
	}

	void setPName(QString strName)
	{
		m_robot->strUser = strName;
	}
	QString getPName()
	{
		return m_robot->strUser;
	}
	QString getPName() const
	{
		return m_robot->strUser;
	}

	void setConnected(bool b)
	{
		m_bConnected = b;
	}
	bool getConnected()
	{
		return m_bConnected;
	}
	bool getConnected() const
	{
		return m_bConnected;
	}

	void setQuitFlag(bool b)
	{
		m_bQuit = b;
	}
	bool getQuitFlag()
	{
		return m_bQuit;
	}

	int getUserType()
	{
		return m_nUserType;
	}
	int getUserType() const
	{
		return m_nUserType;
	}
	void setUserType(int type)
	{
		m_nUserType = type;
	}

	bool doBet(int ind);

	void setUserNameAndPassword(const QString& strUser, const QString& strPass)
	{
		m_robot->strUser = strUser;
		m_robot->strPass = strPass;
	}

	tRobot* getRobot()
	{
		return m_robot;
	}
	const tRobot* getRobot() const
	{
		return m_robot;
	}

	RobotState getRobotStatus()
	{
		return m_robot->rs;
	}
	RobotState getRobotStatus() const
	{
		return m_robot->rs;
	}
	void setRobotStatus(RobotState rs);

	bool isStateChanged()
	{
		return m_bStatusChanged;
	}
	bool isStateChanged() const
	{
		return m_bStatusChanged;
	}
	bool resetStateChanged()
	{
		bool b = m_bStatusChanged;
		if(b)
			m_bStatusChanged = false;
		return b;
	}

private:
	void parsePacket(const QByteArray& ba);
	
Q_SIGNALS:
	//void connectedStateChanged(const QString& pid, bool bConnected);
	//void stateChanged(quint32 msgId, qint32 code);

public Q_SLOTS:
	void dataFromNetwork();

	void onConnected();
	void onDisconnected();

	//void slotTalkMsg(const QString& strMsg);
	//void slotSysTalkMsg(const QString& strMsg);

	void playerEnter(const tPlayer& p);
	void playerLeave(const QString& pid);
	void playersClear();

	void playerState(const QString& pid, int type, int code);
	void setPlayerList(const tPlayerRefMap& prColl, int type);

	void dispTalkMsg(const QString& pid, const QString& strMsg);
	void dispSysTalkMsg(const QString& pid, const QString& strMsg);

	void connectedStateChanged(const QString& pid, bool bConnected);
	void stateChanged(quint32 msgId, qint32 code);

private:
	Connection*		m_cnn;

	PacketBase*		m_pb = nullptr;

	int				m_nUserType = 2;

	bool			m_bConnected = false;

	QByteArray		m_baData;

	bool			m_bQuit = false;

	QString			m_strHostName;
	quint16			m_nPort = 0;

	tRobot*			m_robot = nullptr;

	int				m_nBetNum = 0;
	int				m_nCurNum = 0;

	bool			m_bStatusChanged = false;
};

typedef QMap< QString, ARobot* >	ARobotMap;
typedef QVector< ARobot* >			ARobotVector;

typedef QList< QString >			ARobotKeyList;

typedef QMap< QString, ARobot >		ARobotRefMap;
typedef QVector< ARobot >			ARobotRefVector;



