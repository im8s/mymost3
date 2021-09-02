#pragma once

#include <QRunnable>
#include <QString>
#include <QStringList>


class RobotManager;
class RobotRunnable : public QRunnable
{
public:
	RobotRunnable(RobotManager* rmgr, const QString& strHost, int nPort, const QString& strPrefix, int nS, int nE);
	~RobotRunnable();

protected:
	void run();

private:
	RobotManager*		m_rmgr = nullptr;

	QString				m_strHost;
	int					m_nPort;
	QString				m_strPrefix;
	int					m_nS;
	int					m_nE;
};
