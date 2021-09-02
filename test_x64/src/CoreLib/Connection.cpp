#include "Connection.h"

#include "msg.pb.h"
using namespace pb;

#include <QDebug>
#include <QTime>
#include <QCoreApplication>


Connection::Connection(QObject *parent)
	: QObject(parent)
{
	m_tcpSocket = new QTcpSocket();
}

Connection::~Connection()
{
	delete m_tcpSocket;
}

bool Connection::sendMsg(qint32 msgId, const QByteArray& baData)
{
	DataPacket dp;
	dp.packData(msgId, baData);

	QByteArray& ba = dp.getData();

#if 1
	return sendMsg(ba);
#else
	int sz = m_tcpSocket->write(ba);
	if (sz != ba.size())
	{
		qDebug() << "Connection::sendMsg error";
		return false;
	}

	return true;
#endif
}

bool Connection::sendMsg(qint32 msgId, const string& str)
{
	//qDebug() << "Connection::sendMsg ==> msgId = " << msgId << ", data = " << str.data();

	DataPacket dp;
	dp.packData(msgId, str);

	QByteArray& ba = dp.getData();

#if 1
	return sendMsg(ba);
#else
	int sz = m_tcpSocket->write(ba);
	if (sz != ba.size())
	{
		qDebug() << "Connection::sendMsg error";
		return false;
	}

	return true;
#endif
}

bool Connection::sendMsg(qint32 msgId, const QString& str)
{
	return sendMsg(msgId, str.toStdString());
}

bool Connection::sendMsg(const QByteArray& ba)
{
	//int sz = m_tcpSocket->write(ba);
	////m_tcpSocket->waitForBytesWritten();
	//if (sz != ba.size())
	//{
	//	qDebug() << "Connection::sendMsg error";
	//	return false;
	//}

	const char* ss = ba.data();
	int off = 0;
	int len = ba.size();

	while (off < len)
	{
		int sz = m_tcpSocket->write(&ss[off], len - off);
		if (sz == -1)
		{
			qDebug() << "Connection::sendMsg error: " << m_tcpSocket->errorString();

			return false;
		}

		off += sz;
	}

	return true;
}

bool Connection::sendMsg(const string& str)
{
	QByteArray ba = QByteArray(str.data(), str.size());

	return sendMsg(ba);
}

bool Connection::sendMsg(const QString& str)
{
	return sendMsg(str.toLocal8Bit());
}

