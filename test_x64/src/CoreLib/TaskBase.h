#pragma once

#include "corelib_global.h"

#include <QThread>
#include <QMutex>
#include <QWaitCondition>


class CORELIB_EXPORT TaskBase : public QThread
{
	Q_OBJECT

public:
	TaskBase(QObject *parent = nullptr);
	~TaskBase();

	void toStartup();
	void toShutdown();

	bool getQuitFlag()
	{
		return quit;
	}
	bool getQuitFlag() const
	{
		return quit;
	}

protected:
	void run() override;

	virtual void doWork(){}

signals:

protected:
	QMutex mutex;
	QWaitCondition condition;
	
	bool restart;
	bool quit;
};
