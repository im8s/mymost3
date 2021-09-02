#pragma once

#include "TaskBase.h"

#include <QVector>


class RobotManager;
class TaskRobot : public TaskBase
{
	Q_OBJECT

public:
	TaskRobot(RobotManager* rmgr, const QString& strHost, int nPort, const QString& strPrefix, int nS, int nE, QObject *parent = nullptr);
	~TaskRobot();

protected:
	void doWork();

private:
	RobotManager*	m_rmgr = nullptr;

	QString				m_strHost;
	int					m_nPort;
	QString				m_strPrefix;
	int					m_nS;
	int					m_nE;

	//ARobotMap			m_rbtColl;
	QMutex*				m_rbtLock;
};

typedef QVector< TaskRobot* >	TaskRobotVector;
