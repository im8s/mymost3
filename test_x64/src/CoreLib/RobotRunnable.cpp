#include "RobotRunnable.h"
#include "RobotManager.h"

#include <QThread>


RobotRunnable::RobotRunnable(RobotManager* rmgr, const QString& strHost, int nPort, const QString& strPrefix, int nS, int nE)
	: QRunnable(),m_rmgr(rmgr),m_strHost(strHost),m_nPort(nPort),m_strPrefix(strPrefix),m_nS(nS),m_nE(nE)
{
	
}

RobotRunnable::~RobotRunnable()
{
}

void RobotRunnable::run()
{
	if (m_rmgr)
		m_rmgr->doRunnable(m_strHost, m_nPort, m_strPrefix, m_nS, m_nE);
}

