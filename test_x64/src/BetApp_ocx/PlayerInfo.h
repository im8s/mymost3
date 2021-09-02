#pragma once

#include <QObject>


class PlayerInfo : public QObject
{
	Q_OBJECT

	Q_CLASSINFO("ClassID",		"{DF16845C-92CD-4AAB-A982-EB9840E7467A}")
	Q_CLASSINFO("InterfaceID",	"{616F620B-91C5-4410-A74E-6B81C76FFFF1}")
	Q_CLASSINFO("EventsID",		"{E1816BBA-BF5D-4A31-9855-D6BA43205610}")

public:
	PlayerInfo(QObject *parent = nullptr);
	~PlayerInfo();
	PlayerInfo(const PlayerInfo& other);
	const PlayerInfo& operator = (const PlayerInfo& other);

Q_SIGNALS:

public Q_SLOTS:
	QString getPId()
	{
		return pid;
	}
	const QString getPId() const
	{
		return pid;
	}
	void setPId(const QString& str)
	{
		pid = str;
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
	QString		pid;
	QString		strName;
	int			type;
};

Q_DECLARE_METATYPE(PlayerInfo);

