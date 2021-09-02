#pragma once

#include "corelib_global.h"

#include <QByteArray>
#include <QString>

#include <string>
using namespace std;


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

#pragma pack(push,1)

#define DHEAD_LEN	8

struct CORELIB_EXPORT tDataHead
{
	tDataHead()
	{
		len = 0;
		id = 0;
	}
	~tDataHead()
	{

	}
	tDataHead(const tDataHead& other)
	{
		tDataHead::operator=(other);
	}
	const tDataHead& operator = (const tDataHead& other)
	{
		if (&other != this)
		{
			len = other.len;
			id = other.id;
		}

		return (*this);
	}

	qint32		len;
	qint32		id;
};

struct CORELIB_EXPORT tMsg
{
	tMsg()
	{
	
	}
	~tMsg()
	{

	}
	tMsg(const tMsg& other)
	{
		tMsg::operator=(other);
	}
	const tMsg& operator = (const tMsg& other)
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
};

#pragma pack(pop)

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT DataPacket
{
public:
	DataPacket();
	~DataPacket();

	void reset();

	void packData(qint32 id, const QByteArray& baData);
	void packData(qint32 id, const string& str);
	void packData(qint32 id, const QString& str);
	bool unpackData(QByteArray& ba, tMsg& msg);

	QByteArray& getData()
	{
		return ba;
	}
	const QByteArray& getData() const
	{
		return ba;
	}

private:
	QByteArray		ba;
};

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

