#pragma once

#include "corelib_global.h"

#include "Connection.h"

#include <QObject>


class CORELIB_EXPORT ControlManager : public QObject
{
	Q_OBJECT

public:
	ControlManager(QObject *parent = nullptr);
	~ControlManager();

	bool connectToHost(const QString &hostName, quint16 port, int msecs = 30000);
	bool reconnectToHost(int msecs = 30000);
	void disconnect();

	bool doLoginMsg(const QString& strUser, const QString& strPass);
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

	void setPlayerId(const QString& id)
	{
		m_strPid = id;
	}
	QString getPlayerId()
	{
		return m_strPid;
	}
	const QString getPlayerId() const
	{
		return m_strPid;
	}

	void setPlayerName(QString strName)
	{
		m_strName = strName;
	}
	QString getPlayerName()
	{
		return m_strName;
	}
	QString getPlayerName() const
	{
		return m_strName;
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

	void addPlayer(const tPlayer& p);
	void removePlayer(const QString& pid);
	bool getPlayer(const QString& pid, tPlayer& p);
	void clearAllPlayers();

private:
	void parsePacket(const QByteArray& ba);

	void dispMessage(const tMsg& msg);

	//void processStateMsg(const string& str);
	//void processTalkMsg(const string& str);
	//void processSysTalkMsg(const string& strData);
	//void processChatPlayerMsg(const string& strData);
	//void processPlayerListMsg(const string& strData);
	
signals:
	void connectedStateChanged(bool bConnected);

	void stateChanged(quint32 msgId, qint32 code);

	void dispTalkMsg(const QString& pId, const QString& strName, const string& strContent, int flag);
	
	void processLotteryResMsg(const string& strData);

	void setGStatus(int gs);

	void statusMsgHint(int flag, const QString& strMsg);

	void playerEnter(const tPlayer& p);
	void playerLeave(const QString& pid);
	void playersClear();

public slots:
	void dataFromNetwork();

	void onConnected();
	void onDisconnected();

private:
	Connection*		m_cnn;

	QString			m_strPid;
	QString			m_strName;
	int				m_nUserType = 1;

	tPlayerMap		m_playerColl;
	QMutex			m_playerLock;

	bool			m_bConnected = false;

	QByteArray		m_baData;

	bool			m_bQuit = false;

	QString			m_strHostName;
	quint16			m_nPort = 0;
};
