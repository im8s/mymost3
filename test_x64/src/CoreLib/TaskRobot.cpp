#include "TaskRobot.h"

#include "RobotManager.h"


TaskRobot::TaskRobot(RobotManager* rmgr, const QString& strHost, int nPort, const QString& strPrefix, int nS, int nE, QObject *parent)
	: TaskBase(parent), m_rmgr(rmgr), m_strHost(strHost), m_nPort(nPort), m_strPrefix(strPrefix), m_nS(nS), m_nE(nE)
{
	//toStartup();

	m_rbtLock = new QMutex();
}

TaskRobot::~TaskRobot()
{
	/*for (int k = 0; k < m_rtaskColl.size(); ++k)
	{
		TaskRobot* p = m_rtaskColl[k];
		if (p)
		{
			p->toShutdown();
			delete p;
		}
	}
	m_rtaskColl.clear();*/

	delete m_rbtLock;
}

void TaskRobot::doWork()
{
	if (m_rmgr)
		m_rmgr->doRunnable(m_strHost, m_nPort, m_strPrefix, m_nS, m_nE);
}


