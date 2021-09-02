#pragma once

#include "corelib_global.h"

#include "gdata.h"

#include <QObject>
#include <QMutex>


class LRSettings;
class CORELIB_EXPORT BetManager : public QObject
{
	Q_OBJECT

public:
	BetManager(QObject *parent = nullptr);
	~BetManager();

	bool addBetInfo(tLotJudge& lj, const QString& pid, const QString& strName, const QString& strInfo);
	bool addBetInfo(QString& strMsg, const QString& pid, const QString& strName, const QString& strInfo);
	bool addBetJudge(const tLotJudge& lj);

	bool getBetInfo(const QString& pid, tBetInfo& bi);

	bool getWinLosPoint(LRSettings* lrs, const tLottery& lot, const tBetInfo& bi, float& fv);
	bool getWinLosPoint(LRSettings* lrs, const tLottery& lot, const QString& pid, float& fv);
	bool getWinLosPoint(LRSettings* lrs, const tLottery& lot, const tBetInfo& bi, tPScoreInfo& psi);
	bool getWinLosPoint(LRSettings* lrs, const tLottery& lot, tPScoreInfoRefMap& psiColl);

	QString getBetBill();

	void clearAll();

	int getTotalMount(const QString& pid);
	int getTotalMount(const QString& pid) const;

	void getBetInfoMap(tBetInfoMap& coll)
	{
		QMutexLocker locker(m_biLock);

		coll = m_biColl;
	}
	void getBetInfoMap(tBetInfoMap& coll) const
	{
		QMutexLocker locker(m_biLock);

		coll = m_biColl;
	}

private:
	tBetInfoMap			m_biColl;
	QMutex*				m_biLock;
};
