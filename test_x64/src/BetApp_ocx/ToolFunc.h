#pragma once

#include <QString>


#define ZN_STR(str)	QString::fromLocal8Bit(str)

static bool isDigitStr(const QString& src)
{
	QByteArray ba = src.toLatin1();
	const char *s = ba.data();

	while (*s && *s >= '0' && *s <= '9') s++;

	if (*s || src.isEmpty())
	{
		return false;
	}
	
	return true;
}

