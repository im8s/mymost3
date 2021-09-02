#pragma once

#include <QObject>
#include <QList>


class GroupInfo;
class GroupInfoList : public QObject
{
	Q_OBJECT

	Q_CLASSINFO("ClassID",		"{DF16845C-92CD-4AAB-A982-EB9840E7477B}")
	Q_CLASSINFO("InterfaceID",	"{616F620B-91C5-4410-A74E-6B81C77000F2}")
	Q_CLASSINFO("EventsID",		"{E1816BBA-BF5D-4A31-9855-D6BA43205711}")

public:
	GroupInfoList(QObject *parent = nullptr);
	~GroupInfoList();
	GroupInfoList(const GroupInfoList& other);
	const GroupInfoList& operator = (const GroupInfoList& other);

	int getCount()
	{
		return gilist.size();
	}
	int getCount() const
	{
		return gilist.size();
	}

	GroupInfo* getItem(int ind)
	{
		return gilist[ind];
	}
	const GroupInfo* getItem(int ind) const
	{
		return gilist[ind];
	}

	void clear()
	{
		for (QList< GroupInfo* >::iterator it = gilist.begin();
			it != gilist.end(); ++it)
		{
			GroupInfo* p = (*it);
			delete p;
		}

		gilist.clear();
	}

Q_SIGNALS:

public Q_SLOTS:
	void append(GroupInfo* p);

private:
	QList< GroupInfo* >		gilist;
};

Q_DECLARE_METATYPE(GroupInfoList);

