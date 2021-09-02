#pragma once

#include "corelib_global.h"

#include <QApplication>


class RobotManager;
class CORELIB_EXPORT RobotApplication : public QApplication
{
	Q_OBJECT

public:
	RobotApplication(int &argc, char **argv);
	~RobotApplication();

	static RobotManager* getRManager();

private:
	static RobotManager*	m_rmgr;
};

#define RMGR	(RobotApplication::getRManager())
#define CNN		(RobotApplication::getRManager()->getConnection())
