#pragma once

#include "LotteryQueryGrpcClient.h"

#include "gdata.h"
#include "pdata.h"

#include "LRSettings.h"
#include "LotteryRule.h"

#include "SMachine.h"

#include <QObject>
#include <QMutex>
#include <QVector>
#include <QMap>
#include <QSharedPointer>

#include <string>
using namespace std;


class BetTask;
class BetManager;
class LRSettings;
class LotteryRule;
class ABetRobot;
struct tPlayer;
class PacketBase;
class GroupInfo;
class PlayerInfo;

class BetCtlManager : public QObject
{
	Q_OBJECT

public:
	BetCtlManager(QObject *parent = nullptr);
	~BetCtlManager();

	static BetCtlManager* getInst()
	{
		static BetCtlManager* _inst = new BetCtlManager();
		return _inst;
	}

	void setQuitFlag(bool b)
	{
		m_bQuit = b;
	}
	bool getQuitFlag()
	{
		return m_bQuit;
	}

	void setBetRobotParams(const tLoginParam& lp)
	{
		m_loginParam = lp;

		m_sm->doAction(GA_Idled);
	}

	LRSettings* getLRSettings()
	{
		QMutexLocker locker(m_cfgLock);

		return m_lrSettings;
	}
	const LRSettings* getLRSettings() const
	{
		QMutexLocker locker(m_cfgLock);

		return m_lrSettings;
	}
	void setLRSettings(const LRSettings& lrs)
	{
		QMutexLocker locker(m_cfgLock);

		(*m_lrSettings) = lrs;
	}

	LotteryRule* getLotteryRule()
	{
		return m_lotRule;
	}
	const LotteryRule* getLotteryRule() const
	{
		return m_lotRule;
	}
	void setLotteryRule(const LotteryRule& lr)
	{
		QMutexLocker locker(m_cfgLock);

		(*m_lotRule) = lr;
	}

	tPScoreInfoMap* getPScoreInfoMap()
	{
		QMutexLocker locker(m_psiLock);

		return &m_psiColl;
	}
	const tPScoreInfoMap* getPScoreInfoMap() const
	{
		QMutexLocker locker(m_psiLock);

		return &m_psiColl;
	}
	tPScoreInfoVector* getPScoreInfoVector()
	{
		return &m_tpsiColl;
	}
	const tPScoreInfoVector* getPScoreInfoVector() const
	{
		return &m_tpsiColl;
	}
	bool isExistPScoreInfo(const QString& pid)
	{
		QMutexLocker locker(m_psiLock);

		return m_psiColl.contains(pid);
	}
	void appendPScoreInfo(tPScoreInfo* psi)
	{
		QMutexLocker locker(m_psiLock);

		if (!m_psiColl.contains(psi->pid))
		{
			m_psiColl[psi->pid] = psi;

			m_tpsiColl.append(psi);
		}
	}
	void removePScoreInfo(const QString& pid)
	{
		QMutexLocker locker(m_psiLock);

		if (m_psiColl.contains(pid))
		{
			tPScoreInfo* p = m_psiColl[pid];
			delete p;

			{
				int pos = m_tpsiColl.indexOf(p);
				if (-1 != pos)
					m_tpsiColl.remove(pos);
			}
			
			m_psiColl.remove(pid);
		}
	}
	void clearAllPScoreInfo()
	{
		QMutexLocker locker(m_psiLock);

		for (tPScoreInfoMap::iterator it = m_psiColl.begin();
			it != m_psiColl.end(); ++it)
		{
			tPScoreInfo* p = it.value();
			delete p;
		}

		m_psiColl.clear();

		m_tpsiColl.clear();
	}
	bool getPScoreInfoForTotalScore(const QString& pid, float& fScore)
	{
		QMutexLocker locker(m_psiLock);

		if (m_psiColl.contains(pid))
		{
			tPScoreInfo* psi = m_psiColl[pid];

			fScore = psi->fTotalScore;

			return true;
		}

		return false;
	}
	bool getPScoreInfoForTotalScore(const QString& pid, float& fScore) const
	{
		QMutexLocker locker(m_psiLock);

		if (m_psiColl.contains(pid))
		{
			const tPScoreInfo* psi = m_psiColl[pid];

			fScore = psi->fTotalScore;

			return true;
		}

		return false;
	}
	bool setPScoreInfoForBetString(const QString& pid, const QString& strBetStr)
	{
		QMutexLocker locker(m_psiLock);

		if (m_psiColl.contains(pid))
		{
			tPScoreInfo* psi = m_psiColl[pid];

			psi->strBetStr += strBetStr;

			{
				int pos = m_tpsiColl.indexOf(psi);
				if (-1 != pos)
					m_tpsiColl[pos]->strBetStr = psi->strBetStr;
			}

			return true;
		}

		return false;
	}

	void refreshModelForPSCoreInfo()
	{
		Q_EMIT onRefreshPScoreInfoModel();
	}

	tGroupMap* getGroupInfoMap()
	{
		QMutexLocker locker(m_grpLock);

		return &m_grpColl;
	}
	const tGroupMap* getGroupInfoMap() const
	{
		QMutexLocker locker(m_grpLock);

		return &m_grpColl;
	}
	void getGroupInfoMap(tGroupRefMap& coll)
	{
		QMutexLocker locker(m_grpLock);

		coll.clear();
		for (tGroupMap::iterator it = m_grpColl.begin();
			it != m_grpColl.end(); ++it)
		{
			tGroup* p = it.value();
			
			tGroup grp = (*p);
			coll[grp.gid] = grp;
		}
	}
	void getGroupInfoMap(tGroupRefMap& coll) const
	{
		QMutexLocker locker(m_grpLock);

		coll.clear();
		for (tGroupMap::const_iterator it = m_grpColl.cbegin();
			it != m_grpColl.cend(); ++it)
		{
			const tGroup* p = it.value();

			tGroup grp = (*p);
			coll[grp.gid] = grp;
		}
	}
	void getGroupInfoVector(tGroupRefVector& coll)
	{
		QMutexLocker locker(m_grpLock);

		coll.clear();
		for (tGroupMap::iterator it = m_grpColl.begin();
			it != m_grpColl.end(); ++it)
		{
			tGroup* p = it.value();

			tGroup grp = (*p);
			coll.append(grp);
		}
	}
	void getGroupInfoVector(tGroupRefVector& coll) const
	{
		QMutexLocker locker(m_grpLock);

		coll.clear();
		for (tGroupMap::const_iterator it = m_grpColl.cbegin();
			it != m_grpColl.cend(); ++it)
		{
			const tGroup* p = it.value();

			tGroup grp = (*p);
			coll.append(grp);
		}
	}
	bool getGroupInfo(QString gid, tGroup& p)
	{
		QMutexLocker locker(m_grpLock);

		if (m_grpColl.contains(gid))
		{
			p = (*m_grpColl[gid]);

			return true;
		}

		return false;
	}
	bool getGroupInfo(QString gid, tGroup& p) const
	{
		QMutexLocker locker(m_grpLock);

		if (m_grpColl.contains(gid))
		{
			p = (*m_grpColl[gid]);

			return true;
		}

		return false;
	}
	bool isExistGroup(QString gid)
	{
		QMutexLocker locker(m_grpLock);

		return m_grpColl.contains(gid);
	}
	void appendGroup(tGroup* p)
	{
		QMutexLocker locker(m_grpLock);

		if (!m_grpColl.contains(p->gid))
			m_grpColl[p->gid] = p;
	}
	void appendGroup(const tGroup& p)
	{
		QMutexLocker locker(m_grpLock);

		if (!m_grpColl.contains(p.gid))
		{
			tGroup* pp = new tGroup(p);

			m_grpColl[p.gid] = pp;
		}
	}
	void removeGroup(QString gid)
	{
		QMutexLocker locker(m_grpLock);

		if (m_grpColl.contains(gid))
		{
			tGroup* p = m_grpColl[gid];
			delete p;

			m_grpColl.remove(gid);
		}
	}
	void clearAllGroups()
	{
		QMutexLocker locker(m_grpLock);

		for (tGroupMap::iterator it = m_grpColl.begin();
			it != m_grpColl.end(); ++it)
		{
			tGroup* p = it.value();
			delete p;
		}

		m_grpColl.clear();
	}

	void refreshForGroupInfo()
	{
		Q_EMIT onRefreshGroupInfo();
	}

	tPlayerMap* getPlayerInfoMap()
	{
		QMutexLocker locker(m_playerLock);

		return &m_playerColl;
	}
	const tPlayerMap* getPlayerInfoMap() const
	{
		QMutexLocker locker(m_playerLock);

		return &m_playerColl;
	}
	bool getPlayerInfo(QString pid, tPlayer& p)
	{
		QMutexLocker locker(m_playerLock);

		if (m_playerColl.contains(pid))
		{
			p = (*m_playerColl[pid]);

			return true;
		}

		return false;
	}
	bool getPlayerInfo(QString pid, tPlayer& p) const
	{
		QMutexLocker locker(m_playerLock);

		if (m_playerColl.contains(pid))
		{
			p = (*m_playerColl[pid]);

			return true;
		}

		return false;
	}
	bool isExistPlayer(QString pid)
	{
		QMutexLocker locker(m_playerLock);

		return m_playerColl.contains(pid);
	}
	void appendPlayer(tPlayer* p)
	{
		QMutexLocker locker(m_playerLock);

		if (!m_playerColl.contains(p->pid))
			m_playerColl[p->pid] = p;
	}
	void appendPlayer(const tPlayer& p)
	{
		QMutexLocker locker(m_playerLock);

		if (!m_playerColl.contains(p.pid))
		{
			tPlayer* pp = new tPlayer(p);

			m_playerColl[p.pid] = pp;
		}
	}
	void removePlayer(QString pid)
	{
		QMutexLocker locker(m_playerLock);

		if (m_playerColl.contains(pid))
		{
			tPlayer* p = m_playerColl[pid];
			delete p;

			m_playerColl.remove(pid);
		}
	}
	void clearAllPlayers()
	{
		QMutexLocker locker(m_playerLock);

		for (tPlayerMap::iterator it = m_playerColl.begin();
			it != m_playerColl.end(); ++it)
		{
			tPlayer* p = it.value();
			delete p;
		}

		m_playerColl.clear();
	}

	tLotteryMap* getLotteryInfoMap()
	{
		QMutexLocker locker(m_lotLock);

		return &m_lotColl;
	}
	const tLotteryMap* getLotteryInfoMap() const
	{
		QMutexLocker locker(m_lotLock);

		return &m_lotColl;
	}
	bool getLotteryInfo(qint32 nPeriods, tLottery& p)
	{
		QMutexLocker locker(m_lotLock);

		if (m_lotColl.contains(nPeriods))
		{
			p = (*m_lotColl[nPeriods]);

			return true;
		}

		return false;
	}
	bool getLotteryInfo(qint32 nPeriods, tLottery& p) const
	{
		QMutexLocker locker(m_lotLock);

		if (m_lotColl.contains(nPeriods))
		{
			p = (*m_lotColl[nPeriods]);

			return true;
		}

		return false;
	}
	bool isExistLottery(qint32 nPeriods)
	{
		QMutexLocker locker(m_lotLock);

		return m_lotColl.contains(nPeriods);
	}
	void appendLottery(tLottery* p)
	{
		QMutexLocker locker(m_lotLock);

		if (!m_lotColl.contains(p->nPeriods))
			m_lotColl[p->nPeriods] = p;
	}
	void appendLottery(const tLottery& p)
	{
		QMutexLocker locker(m_lotLock);

		if (!m_lotColl.contains(p.nPeriods))
		{
			tLottery* pp = new tLottery(p);

			m_lotColl[p.nPeriods] = pp;
		}
	}
	void removeLottery(qint32 nPeriods)
	{
		QMutexLocker locker(m_lotLock);

		if (m_lotColl.contains(nPeriods))
		{
			tLottery* p = m_lotColl[nPeriods];
			delete p;

			m_lotColl.remove(nPeriods);
		}
	}
	void clearAllLotterys()
	{
		QMutexLocker locker(m_lotLock);

		for (tLotteryMap::iterator it = m_lotColl.begin();
			it != m_lotColl.end(); ++it)
		{
			tLottery* p = it.value();
			delete p;
		}

		m_lotColl.clear();
	}

	void refreshModelForLotteryInfo()
	{
		Q_EMIT onRefreshLotteryInfoModel();
	}

	bool getSysStartup()
	{
		return m_bSysStartup;
	}
	bool getSysStartup() const
	{
		return m_bSysStartup;
	}
	void setSysStartup(bool b)
	{
		m_bSysStartup = b;
	}

	bool caculateWaitLotterySecondsLeft(int flag, int& secs, QString& strDat);
	//bool caculateDrawLotterySecondsLeft(int& secs);

	void doTaskLoop();

	void doAction(int gs);

	bool saveConfigFromFile()
	{
		return saveConfigFromFile(m_strXmlFilePath);
	}

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr);

	bool getWinLosPoint(const tLottery& lot, const tLotJudge& lj, float& fv);
	bool getWinLosPoint(const tLottery& lot, const tLotJudge& lj, int nTotalMount, float& fv);
	bool getWinLosPoint(const tLottery& lot, const tBetInfo& bi, float& fv);
	bool getWinLosPoint(const tLottery& lot);

	QString getScoreBoard();

	void resetNeeded();

	bool isCountdownExpired(int gs);

	void setGStatus(GStatus gs);

	BetTask* getBetTask()
	{
		return m_pTaskBet;
	}
	const BetTask* getBetTask() const
	{
		return m_pTaskBet;
	}

	void talkMsg(const QString& strMsg);
	void sysTalkMsg(const QString& strMsg);

	void lotteryRequest(int type);
	void processLotteryResMsg(const LotteryResponse& msg);

	void putReceivedMsgToQueue(const QString& pid, const QString& strName, const QString& strContent, int flag);

#if 1
	void msgArrived(const QString& pid, const QString& strName, const QString& strMsg);
#else
	void msgArrived(const QString& gid, const QString& pid, const QString& strName, const QString& strMsg);
#endif

	void notifyGroupInfo(const QVariant& v);
	void notifyGroupCreated(const QVariant& v);
	void notifyGroupDeleted(const QString& gid);

	void notifyMemberInfo(const QVariant& v);
	void notifyMemberJoin(const QVariant& v);
	void notifyMemberLeave(const QString& pid);

	QString& getGroupID()
	{
		return m_strGrpId;
	}
	const QString& getGroupID() const
	{
		return m_strGrpId;
	}
	void setGroupID(const QString& strId)
	{
		m_strGrpId = strId;
	}

	void doSMAction(GAction ga)
	{
		m_sm->doAction(ga);
	}

protected:
	bool msgSend(const QString& strMsg);

private:
	bool loadConfigFromFile(const QString& strXmlFilePath);
	bool saveConfigFromFile(const QString& strXmlFilePath);

	void updateStatusInfo(qint32 type, qint32 code);
	void updateSMInfo(int gs);

	bool doBet(const QString& strBetStr, const QString& pid, const QString& strName);
	bool doBet(const tBetMsg& bm);
	void doBet(int nCnt);

signals:
	void dispTalkMsg(const QString& pid, const QString& strName, const QString& strContent, int flag);
	
	void dispALottery(int,const tLottery& lot);
	void dispDrawLotteryTimeLeft(const QString& strDat);
	void statusMsgHint(int flag, const QString& strMsg);

	void onRefreshPScoreInfoModel();
	void onRefreshLotteryInfoModel();
	void onRefreshGroupInfo();

	void sigMsgSend(const QString& gid, const QString& strMsg);

public slots:
	void playerEnter(const tPlayer& p);
	void playerLeave(const QString& pid);
	void playersClear();

	void playerState(const QString& pid, int type, int code);
	void setPlayerList(const tPlayerRefMap& prColl, int type);

	void dispTalkMsg(const QString& pid, const QString& strMsg);
	void dispSysTalkMsg(const QString& pid, const QString& strMsg);

	void setLotteryState(int type, int code);
	void setLotteryServerTime(const tServerTime& st);
	void setLotteryHistory(const tLotteryRefMap& coll);
	void setLotteryNext(const tLottery& lot);
	void setLotteryLatest(const tLottery& lot);

	void connectedStateChanged(const QString& pid, bool bConnected);
	void stateChanged(quint32 msgId, qint32 code);

	void onClearAll();

private:
	tLotteryMap		m_lotColl;
	QMutex*			m_lotLock;

#define MAX_LOTTERY_INCOLL		50

	qint64			m_dtDelta = 0;
	int				m_dtGap = 210;
	int				m_nNextPeriods = 0;
	qint64			m_dtNextPeriods = 0;

	SMachine*		m_sm = nullptr;
	
	bool			m_bSysStartup = false;
	bool			m_bBetStartup = false;

	LotteryQueryGrpcClient*	m_lqgClient = nullptr;

	tLottery		m_curlot;

	BetTask*		m_pTaskBet = nullptr;
	BetManager*		m_pBetMgr = nullptr;

	tLoginParam		m_loginParam;

	LRSettings*		m_lrSettings = nullptr;
	LotteryRule*	m_lotRule = nullptr;
	QMutex*			m_cfgLock;

	tPScoreInfoMap	m_psiColl;
	QMutex*			m_psiLock;

	tPScoreInfoVector	m_tpsiColl;

	tGroupMap		m_grpColl;
	QMutex*			m_grpLock;

	tPlayerMap		m_playerColl;
	QMutex*			m_playerLock;

	tBetMsgVector	m_bmColl;
	QMutex*			m_bmLock;

	bool			m_bQuit = false;

	QString			m_strXmlFilePath;

	QString			m_strGrpId;

	QStringList		m_strlstFilter;
};

#define BCMGR	(BetCtlManager::getInst())
#define CNN		(BetCtlManager::getInst().getConnection())