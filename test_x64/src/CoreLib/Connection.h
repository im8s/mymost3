#pragma once

#include "corelib_global.h"

#include <QObject>
#include <QTcpSocket>
#include <QMutex>
#include <QMutexLocker>

#include <string>
using namespace std;

#include "DataPacket.h"
#include "pdata.h"


class CORELIB_EXPORT Connection : public QObject
{
	Q_OBJECT

public:
	Connection(QObject *parent = nullptr);
	~Connection();

	bool sendMsg(qint32 msgId, const QByteArray& baData);
	bool sendMsg(qint32 msgId, const string& str);
	bool sendMsg(qint32 msgId, const QString& str);

	bool sendMsg(const QByteArray& baData);
	bool sendMsg(const string& str);
	bool sendMsg(const QString& str);

	QTcpSocket* getTcpSocket()
	{
		return m_tcpSocket;
	}
	const QTcpSocket* getTcpSocket() const
	{
		return m_tcpSocket;
	}

protected:
	QTcpSocket*		m_tcpSocket;
};
