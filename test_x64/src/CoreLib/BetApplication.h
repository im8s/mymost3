#pragma once

#include "corelib_global.h"

#include <QApplication>


class BetCtlManager;
class CORELIB_EXPORT BetApplication : public QApplication
{
	Q_OBJECT

public:
	BetApplication(int &argc, char **argv);
	~BetApplication();

	static BetCtlManager* getBCManager();

private:
	static BetCtlManager*	m_bcmgr;
};

#define BCMGR	(BetApplication::getBCManager())
#define CNN		(BetApplication::getBCManager()->getConnection())
