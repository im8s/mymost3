#pragma once

#include "corelib_global.h"

#include "ARobot.h"

#include "TaskRobot.h"

#include <QObject>
#include <QMap>
#include <QVector>
#include <QMutex>


class QThreadPool;
class CORELIB_EXPORT RobotManager : public QObject
{
	Q_OBJECT

public:
	RobotManager(QObject *parent = nullptr);
	~RobotManager();

	void toDoWork(const QString& strHost, int nPort, int nThreadNum, const QString& strPrefix, int nRobotNum);

	void doRunnable(const QString& strHost, int nPort, const QString& strPrefix, int nS, int nE);
	
	bool getResetFlag()
	{
		return m_bReset;
	}
	bool getResetFlag() const
	{
		return m_bReset;
	}
	void setResetFlag(bool b)
	{
		m_bReset = b;
	}

	void getRobotColl(tRobotVector& coll)
	{
		QMutexLocker locker(m_rbtLock);

		coll.clear();
		for (ARobotMap::iterator it = m_rbtColl.begin(); 
			it != m_rbtColl.end(); ++it)
		{
			ARobot* ar = it.value();
			tRobot* r = ar->getRobot();

			coll.append(r);
		}
	}
	void getRobotColl(tRobotVector& coll) const
	{
		QMutexLocker locker(m_rbtLock);

		coll.clear();
		for (ARobotMap::const_iterator it = m_rbtColl.cbegin();
			it != m_rbtColl.cend(); ++it)
		{
			ARobot* ar = it.value();
			tRobot* r = ar->getRobot();

			coll.append(r);
		}
	}

	tRobotVector* getRobotVector()
	{
		return &m_trbtColl;
	}
	const tRobotVector* getRobotVector() const
	{
		return &m_trbtColl;
	}

	/*ARobotMap* getRobotCollRef()
	{
		return &m_rbtColl;
	}
	const ARobotMap* getRobotCollRef() const
	{
		return &m_rbtColl;
	}*/
	
	void refreshModel()
	{
		Q_EMIT onRefreshModel();
	}

signals:
	void onRefreshModel();

	void sigRobotTaskQuit();

public slots:

private:
	void clearAll(const QStringList& keylst);

private:
	ARobotMap			m_rbtColl;
	QMutex*				m_rbtLock;

	tRobotVector		m_trbtColl;

	TaskRobotVector		m_rtaskColl;

	QString				m_strHostName;
	int					m_nPort = 0;
	int					m_nThreadNum = 0;

	QString				m_strPrefix;
	int					m_nRobotNum = 0;
	
	bool				m_bReset = false;

	bool				m_bQuit = false;
};
