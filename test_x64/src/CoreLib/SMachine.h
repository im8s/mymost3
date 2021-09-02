#pragma once

#include <QObject>
#include <QMutex>


enum GStatus
{
	GS_idle = 0,
	GS_init,
	GS_connecting,
	GS_connected,
	GS_logining,
	GS_logined,
	GS_fetchplayerlist,
	GS_fetchservertime,
	GS_fetchlothistory,
	GS_curlotperiods,
	GS_openbet,
	GS_waitfordrawlot,
	GS_closebet,
	GS_fetchlatestlot,
	GS_calculot,
	GS_disconnecting,
	GS_disconnected,
};

enum GAction
{
	GA_Idled = 0,

	GA_InitedDone,
	
	GA_ConnectingDone,
	GA_ConnectedDone,
	GA_LoginingDone,
	GA_LoginedDone,
	GS_fetchplayerlistDone,

	GA_ServerTimeDone,
	GA_FetchLotHistoryDone,

	GA_CurrentPeriodsDone,
	GA_OpenBetDone,
	GA_WaitForDrawLotDone,
	GA_CloseBetDone,
	GA_FetchLatestLotDone,
	GA_PSCoreDone,
	GA_DisconnectingDone,
	GA_DisconnectedDone,
};

class SMachine : public QObject
{
	Q_OBJECT

public:
	SMachine(QObject *parent = nullptr);
	~SMachine();

	GStatus getGStatus()
	{
		QMutexLocker locker(m_gsLock);

		return m_gs;
	}
	GStatus getGStatus() const
	{
		QMutexLocker locker(m_gsLock);

		return m_gs;
	}
	void setGStatus(GStatus gs)
	{
		QMutexLocker locker(m_gsLock);

		m_gs = gs;
	}

	void doAction(GAction gs);

	QString getGSString(int gs);

private:
	GStatus			m_gs;
	QMutex*			m_gsLock;

};
