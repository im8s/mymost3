#include "BetApplication.h"
#include "BetCtlManager.h"


BetCtlManager*	BetApplication::m_bcmgr = nullptr;

BetApplication::BetApplication(int &argc, char **argv)
	: QApplication(argc,argv)
{
	m_bcmgr = new BetCtlManager();
}

BetApplication::~BetApplication()
{
	delete m_bcmgr;
}

BetCtlManager* BetApplication::getBCManager()
{
	return m_bcmgr;
}



