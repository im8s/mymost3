#include "BetTask.h"

#include "BetApplication.h"
#include "BetCtlManager.h"


BetTask::BetTask(BetCtlManager* bcmgr, QObject *parent)
	: TaskBase(parent), m_bcmgr(bcmgr)
{
	toStartup();
}

BetTask::~BetTask()
{
}

void BetTask::doWork()
{
	if(m_bcmgr)
		m_bcmgr->doTaskLoop();
}

//void BetTask::slotTalkMsg(const QString& strMsg)
//{
//	BCMGR->doTalkMsg(strMsg);
//}
//
//void BetTask::slotSysTalkMsg(const QString& strMsg)
//{
//	BCMGR->doSysTalkMsg(strMsg);
//}


