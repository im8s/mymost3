#include "DataPacket.h"

#include <QDebug>


DataPacket::DataPacket()
{
	reset();
}

DataPacket::~DataPacket()
{

}

void DataPacket::reset()
{
	ba.clear();

	tDataHead h;
	ba.append((char*)&h, sizeof(tDataHead));
}

void DataPacket::packData(qint32 id, const QByteArray& baData)
{
	ba += baData;

	const char* ss = ba.data();
	tDataHead* h = (tDataHead*)ss;
	h->len = ba.size() - DHEAD_LEN;
	h->id = id;

	//qDebug() << "DataPacket::packData ==> h->id = " << h->id << ", h->len = " << h->len;
}

void DataPacket::packData(qint32 id, const string& str)
{
	ba += str.data();

	const char* ss = ba.data();
	tDataHead* h = (tDataHead*)ss;
	h->len = ba.size() - DHEAD_LEN;
	h->id = id;

	//qDebug() << "DataPacket::packData ==> h->id = " << h->id << ", h->len = " << h->len;
}

void DataPacket::packData(qint32 id, const QString& str)
{
	ba += str.toLocal8Bit();

	const char* ss = ba.data();
	tDataHead* h = (tDataHead*)ss;
	h->len = ba.size() - DHEAD_LEN;
	h->id = id;

	//qDebug() << "DataPacket::packData2 ==> h->id = " << h->id << ", h->len = " << h->len;
}

bool DataPacket::unpackData(QByteArray& ba, tMsg& msg)
{
	if (ba.size() > DHEAD_LEN)
	{
		const char* ss = ba.data();
		tDataHead* h = (tDataHead*)ss;
		if (DHEAD_LEN + h->len <= ba.size())
		{
			msg.dh = (*h);
			msg.str = QByteArray(ss + sizeof(tDataHead), h->len);

			ba.remove(0, DHEAD_LEN + h->len);

			return true;
		}
	}

	return false;
}
