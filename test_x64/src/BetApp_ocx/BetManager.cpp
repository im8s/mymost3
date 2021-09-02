#include "BetManager.h"

#include <QMutexLocker>
#include <QDebug>

#include "LRSettings.h"


BetManager::BetManager(QObject *parent)
	: QObject(parent)
{
	m_biLock = new QMutex();
}

BetManager::~BetManager()
{
	clearAll();

	delete m_biLock;
}

bool BetManager::addBetInfo(tLotJudge& lj, const QString& pid, const QString& strName, const QString& strInfo)
{
	return lj.addBetInfo(pid, strName, strInfo);
}

bool BetManager::addBetInfo(QString& strMsg, const QString& pid, const QString& strName, const QString& strInfo)
{
	tLotJudge lj;
	if (addBetInfo(lj, pid, strName, strInfo))
	{
		strMsg = ZN_STR("PID = %1 ==> ").arg(pid) + lj.asString();

		return addBetJudge(lj);
	}

	return false;
}

bool BetManager::addBetJudge(const tLotJudge& lj)
{
	QMutexLocker locker(m_biLock);

	if (!m_biColl.contains(lj.pid))
	{
		m_biColl[lj.pid] = tBetInfo(lj.pid,lj.strName);
	}

	m_biColl[lj.pid].append(lj);

	return true;
}

bool BetManager::getBetInfo(const QString& pid, tBetInfo& bi)
{
	QMutexLocker locker(m_biLock);

	if (m_biColl.contains(pid))
	{
		bi = m_biColl[pid];

		return true;
	}

	return false;
}

bool BetManager::getWinLosPoint(LRSettings* lrs, const tLottery& lot, const tBetInfo& bi, float& fv)
{
	{
		fv = 0;
		int nTotalMount = bi.getTotalMount();

		qDebug() << "¿ª½±ºÅÂë£º" << lot.asAllResult();

		for (int k = 0; k < bi.ljColl.size(); ++k)
		{
			const tLotJudge& lj = bi.ljColl[k];

			float flr = 0;
			if (!lrs->getLostrate(lot, lj, nTotalMount, flr))
				return false;

			fv += (flr - 1) * lj.nAmount;

			qDebug() << k << " " << lj.asString() << ", ÊäÓ®·Ö£º" << (flr - 1)*lj.nAmount;
		}

		qDebug() << "×ÜÊäÓ®·Ö£º" << fv << "\n\n";
	}

	return true;
}

bool BetManager::getWinLosPoint(LRSettings* lrs, const tLottery& lot, const QString& pid, float& fv)
{
	tBetInfo bi;
	bool bExist = false;
	{
		QMutexLocker locker(m_biLock);

		if (m_biColl.contains(pid))
		{
			bi = m_biColl[pid];
			bExist = true;
		}
	}

	if (bExist)
		return getWinLosPoint(lrs, lot, bi, fv);

	return false;
}

bool BetManager::getWinLosPoint(LRSettings* lrs, const tLottery& lot, const tBetInfo& bi, tPScoreInfo& psi)
{
	{
		int nTotalMount = bi.getTotalMount();

		psi.nThisLotNum = bi.ljColl.size();
		psi.nAccLotNum = psi.nThisLotNum;
		psi.nAccTurnNum = 1;

		//qDebug() << "¿ª½±ºÅÂë£º" << lot.asAllResult();

		QString strBetStr;

		for (int k = 0; k < bi.ljColl.size(); ++k)
		{
			const tLotJudge& lj = bi.ljColl[k];

			float flr = 0;
			if (!lrs->getLostrate(lot, lj, nTotalMount, flr))
				return false;

			float fv = (flr - 1) * lj.nAmount;

			psi.fThisScore += fv;
			psi.fThisPayment += lj.nAmount;

			if (fv > 0)
			{
				psi.fThisWScore += fv;
				psi.nThisWLotNum += 1;
			}
			else if (fv < 0)
			{
				psi.fThisLScore += fv;
				psi.nThisLLotNum += 1;
			}

			if (!strBetStr.isEmpty())
				strBetStr += ";";
			strBetStr += lj.strBet;

			//qDebug() << k << " " << lj.asString() << ", ÊäÓ®·Ö£º" << fv;
		}

		//psi.strBetStr = strBetStr;

		psi.fAccScore = psi.fThisScore;
		psi.fAccPayment = psi.fThisPayment;

		psi.fAccWScore = psi.fThisWScore;
		psi.fAccLScore = psi.fThisLScore;

		psi.nAccWLotNum = psi.nThisWLotNum;
		psi.nAccLLotNum = psi.nThisLLotNum;

		psi.fTotalScore += psi.fAccScore;

		//qDebug() << "×ÜÊäÓ®·Ö£º" << psi.fThisWScore << "\n\n";
	}

	return true;
}

bool BetManager::getWinLosPoint(LRSettings* lrs, const tLottery& lot, tPScoreInfoRefMap& psiColl)
{
	psiColl.clear();

	tBetInfoMap	biColl;
	{
		QMutexLocker locker(m_biLock);

		biColl = m_biColl;
	}

	for (tBetInfoMap::ConstIterator cit = biColl.begin();
		cit != biColl.end(); ++cit)
	{
		const tBetInfo& bi = cit.value();

		tPScoreInfo psi;
		if (getWinLosPoint(lrs, lot, bi, psi))
		{
			psi.pid = bi.pid;
			psi.strName = bi.strName;

			psiColl[psi.pid] = psi;
		}
	}

	return true;
}

QString BetManager::getBetBill()
{
	tBetInfoMap	biColl;
	{
		QMutexLocker locker(m_biLock);

		biColl = m_biColl;
	}

	QString strBill;

	for (tBetInfoMap::iterator it = biColl.begin();
		it != biColl.end(); ++it)
	{
		tBetInfo& bi = it.value();

		strBill += ZN_STR("%1 [¹²%2×¢]: \n").arg(bi.strName).arg(bi.ljColl.size()) + bi.getBetBill() + "\n";
	}

	return strBill;
}

void BetManager::clearAll()
{
	QMutexLocker locker(m_biLock);

	m_biColl.clear();
}

int BetManager::getTotalMount(const QString& pid)
{
	QMutexLocker locker(m_biLock);

	int mount = 0;

	if (m_biColl.contains(pid))
	{
		tBetInfo& bi = m_biColl[pid];

		mount = bi.getTotalMount();
	}

	return mount;
}

int BetManager::getTotalMount(const QString& pid) const
{
	QMutexLocker locker(m_biLock);

	int mount = 0;

	if (m_biColl.contains(pid))
	{
		const tBetInfo& bi = m_biColl[pid];

		mount = bi.getTotalMount();
	}

	return mount;
}

