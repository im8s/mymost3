#pragma once

#include <QObject>
#include <QList>


class PlayerInfo;
class PlayerInfoList : public QObject
{
	Q_OBJECT

	Q_CLASSINFO("ClassID",		"{DF16845C-92CD-4AAB-A982-EB9840E7467B}")
	Q_CLASSINFO("InterfaceID",	"{616F620B-91C5-4410-A74E-6B81C76FFFF2}")
	Q_CLASSINFO("EventsID",		"{E1816BBA-BF5D-4A31-9855-D6BA43205611}")

public:
	PlayerInfoList(QObject *parent = nullptr);
	~PlayerInfoList();
	PlayerInfoList(const PlayerInfoList& other);
	const PlayerInfoList& operator = (const PlayerInfoList& other);

	int getCount()
	{
		return pilist.size();
	}
	int getCount() const
	{
		return pilist.size();
	}

	PlayerInfo* getItem(int ind)
	{
		return pilist[ind];
	}
	PlayerInfo* getItem(int ind) const
	{
		return pilist[ind];
	}

	void clear()
	{
		for (QList< PlayerInfo* >::iterator it = pilist.begin();
			it != pilist.end(); ++it)
		{
			PlayerInfo* p = (*it);
			delete p;
		}

		pilist.clear();
	}

Q_SIGNALS:

public Q_SLOTS:
	void append(PlayerInfo* p);

private:
	QList< PlayerInfo* >		pilist;
};

Q_DECLARE_METATYPE(PlayerInfoList);

