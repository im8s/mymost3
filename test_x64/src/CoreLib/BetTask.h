#pragma once

#include "TaskBase.h"


class BetCtlManager;
class BetTask : public TaskBase
{
	Q_OBJECT

public:
	BetTask(BetCtlManager* bcmgr, QObject *parent = nullptr);
	~BetTask();

protected:
	void doWork();

signals:

public slots:
	//void slotTalkMsg(const QString& strMsg);
	//void slotSysTalkMsg(const QString& strMsg);

private:
	BetCtlManager*	m_bcmgr = nullptr;
};
