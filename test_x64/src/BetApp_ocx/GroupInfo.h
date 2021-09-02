#pragma once

#include <QObject>


class GroupInfo : public QObject
{
	Q_OBJECT

	Q_CLASSINFO("ClassID",		"{DF16845C-92CD-4AAB-A982-EB9840E7477A}")
	Q_CLASSINFO("InterfaceID",	"{616F620B-91C5-4410-A74E-6B81C77000F1}")
	Q_CLASSINFO("EventsID",		"{E1816BBA-BF5D-4A31-9855-D6BA43205710}")

public:
	GroupInfo(QObject *parent = nullptr);
	~GroupInfo();
	GroupInfo(const GroupInfo& other);
	const GroupInfo& operator = (const GroupInfo& other);

Q_SIGNALS:

public Q_SLOTS:
	QString getGId()
	{
		return gid;
	}
	const QString getGId() const
	{
		return gid;
	}
	void setGId(const QString& str)
	{
		gid = str;
	}

	QString getName()
	{
		return strName;
	}
	const QString getName() const
	{
		return strName;
	}
	void setName(const QString& str)
	{
		strName = str;
	}

	int getType()
	{
		return type;
	}
	int getType() const
	{
		return type;
	}
	void setType(int n)
	{
		type = n;
	}

private:
	QString		gid;
	QString		strName;
	int			type;
};

Q_DECLARE_METATYPE(GroupInfo);

