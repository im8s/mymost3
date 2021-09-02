#include "RobotApplication.h"

#include "RobotManager.h"


RobotManager*	RobotApplication::m_rmgr = nullptr;

RobotApplication::RobotApplication(int &argc, char **argv)
	: QApplication(argc,argv)
{
	m_rmgr = new RobotManager();
}

RobotApplication::~RobotApplication()
{
	delete m_rmgr;
}

RobotManager* RobotApplication::getRManager()
{
	return m_rmgr;
}



