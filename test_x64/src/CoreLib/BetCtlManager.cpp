#include "BetCtlManager.h"

#include "ABetRobot.h"

#include "BetTask.h"
#include "BetManager.h"

#include "Packet.h"

#include "msg.pb.h"
using namespace pb;

#include <QCoreApplication>
#include <QDebug>
#include <QElapsedTimer>

#include "tinyxml2.h"
using namespace tinyxml2;


static QString getTimeLeftString(int flag, int secs)
{
	QString strDt;

	if (0 == flag)
	{
		int mins = secs / 60;
		secs -= mins * 60;
		strDt = ZN_STR("%1分%2秒").arg(mins).arg(secs);
	}
	else if (1 == flag)
	{
		int mins = secs / 60;
		secs -= mins * 60;
		strDt = ZN_STR("等待结果...%1分%2秒").arg(mins).arg(secs);
	}

	return strDt;
}

BetCtlManager::BetCtlManager(QObject *parent)
	: QObject(parent)
{
	qRegisterMetaType<tPlayer>("tPlayer");
	qRegisterMetaType<tPlayer>("tPlayer&");

	qRegisterMetaType<tPlayerRefMap>("tPlayerRefMap");
	qRegisterMetaType<tPlayerRefMap>("tPlayerRefMap&");

	qRegisterMetaType<tLottery>("tLottery");
	qRegisterMetaType<tLottery>("tLottery&");

	qRegisterMetaType<tLotteryRefMap>("tLotteryRefMap");
	qRegisterMetaType<tLotteryRefMap>("tLotteryRefMap&");

	qRegisterMetaType<tServerTime>("tServerTime");
	qRegisterMetaType<tServerTime>("tServerTime&");

	m_lotLock = new QMutex();
	m_cfgLock = new QMutex();
	m_psiLock = new QMutex();
	m_playerLock = new QMutex();
	m_bmLock = new QMutex();
	m_bdsLock = new QMutex();

	//m_pb = new Packet();

	m_sm = new SMachine();

	m_pTaskBet = new BetTask(this);
	m_pBetMgr = new BetManager(this);

	m_lrSettings = new LRSettings();
	m_lotRule = new LotteryRule();

	m_lqgClient = new LotteryQueryGrpcClient();
	{
		m_lqgClient->setParams("192.168.59.130", 8090);

		QObject::connect(m_lqgClient, SIGNAL(setLotteryState(int, int)), this, SLOT(setLotteryState(int, int)));
		QObject::connect(m_lqgClient, SIGNAL(setLotteryServerTime(const tServerTime&)), this, SLOT(setLotteryServerTime(const tServerTime&)));
		QObject::connect(m_lqgClient, SIGNAL(setLotteryHistory(const tLotteryRefMap&)), this, SLOT(setLotteryHistory(const tLotteryRefMap&)));
		QObject::connect(m_lqgClient, SIGNAL(setLotteryNext(const tLottery&)), this, SLOT(setLotteryNext(const tLottery&)));
		QObject::connect(m_lqgClient, SIGNAL(setLotteryLatest(const tLottery&)), this, SLOT(setLotteryLatest(const tLottery&)));
	}

	{
		//m_betRbt = new ABetRobot();

		//QObject::connect(m_betRbt, SIGNAL(connectedStateChanged(qint32, bool)), this, SLOT(slotConnectedStateChanged(qint32, bool)));
		//QObject::connect(m_betRbt, SIGNAL(stateChanged(quint32, qint32)), this, SLOT(slotStateChanged(quint32, qint32)));
		//QObject::connect(m_betRbt, SIGNAL(dispTalkMsg(qint32, const QString&, const QString&, int)), this, SLOT(slotDispTalkMsg(qint32, const QString&, const QString&, int)));

		//QObject::connect(this, SIGNAL(sigTalkMsg(const QString&)), m_betRbt, SLOT(slotTalkMsg(const QString&)));
		//QObject::connect(this, SIGNAL(sigSysTalkMsg(const QString&)), m_betRbt, SLOT(slotSysTalkMsg(const QString&)));
	}

	//QObject::connect(this, SIGNAL(sigDoAction(int)), this, SLOT(slotDoAction(int)));
	//QObject::connect(this, SIGNAL(sigSysTalkMsg(const QString&)), this, SLOT(slotSysTalkMsg(const QString&)));

	/*QObject::connect(m_cmgr, SIGNAL(processLotteryResMsg(const string&)), this, SLOT(processLotteryResMsg(const string&)));
	QObject::connect(m_cmgr, SIGNAL(dispTalkMsg(qint32, const QString&, const string&, int)), this, SLOT(dispTalkMsg(qint32, const QString&, const string&, int)));
	QObject::connect(m_cmgr, SIGNAL(setGStatus(int)), this, SLOT(setGStatus(int)));

	QObject::connect(m_cmgr, SIGNAL(playerEnter(const tPlayer&)), this, SLOT(playerEnter(const tPlayer&)));
	QObject::connect(m_cmgr, SIGNAL(playerLeave(qint32)), this, SLOT(playerLeave(qint32)));
	QObject::connect(m_cmgr, SIGNAL(playersClear()), this, SLOT(playersClear()));

	QObject::connect(m_cmgr, SIGNAL(connectedStateChanged(bool)), this, SLOT(connectedStateChanged(bool)));*/

	{
		QString strFilePath = QCoreApplication::applicationDirPath();
		strFilePath += "/config.xml";
		if (!loadConfigFromFile(strFilePath))
		{
			qDebug() << "loadConfigFromFile failure";
		}

		m_strXmlFilePath = strFilePath;
	}
}

BetCtlManager::~BetCtlManager()
{
	m_bQuit = true;

	if (!saveConfigFromFile(m_strXmlFilePath))
	{
		qDebug() << "saveConfigFromFile failure";
	}

	clearAllPScoreInfo();
	clearAllPlayers();
	clearAllLotterys();

	delete m_pTaskBet;
	delete m_pBetMgr;
	delete m_lrSettings;
	delete m_lotRule;
	//delete m_betRbt;

	delete m_sm;
	delete m_pb;

	delete m_lqgClient;

	delete m_lotLock;
	delete m_cfgLock;
	delete m_psiLock;
	delete m_playerLock;
	delete m_bmLock;
	delete m_bdsLock;
}

void BetCtlManager::parsePacket(const QByteArray& ba)
{
	m_pb->parsePacket(ba);
}

bool BetCtlManager::checkRules(const tLotJudge& lj, QString& strMsg)
{
	QMutexLocker locker(m_cfgLock);

	LRSettings* lrs = m_lrSettings;
	LotteryRule* lr = m_lotRule;

	if (!lrs->checkRules(lj, strMsg))
		return false;

	tBetInfo bi;
	m_pBetMgr->getBetInfo(lj.pid, bi);
	{
		if (!lr->checkRules(lj, bi, strMsg))
			return false;
	}

	return true;
}

bool BetCtlManager::getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr)
{
	LRSettings lrs;
	{
		QMutexLocker locker(m_cfgLock);

		lrs = (*m_lrSettings);
	}
	
	{
		flr = 0;
		int nTotalMount = lj.nAmount;

		if (!lrs.getLostrate(lot, lj, nTotalMount, flr))
			return false;
	}

	return true;
}

bool BetCtlManager::getWinLosPoint(const tLottery& lot, const tLotJudge& lj, float& fv)
{
	LRSettings lrs;
	{
		QMutexLocker locker(m_cfgLock);

		lrs = (*m_lrSettings);
	}

	{
		fv = 0;
		int nTotalMount = lj.nAmount;

		if (!lrs.getLostrate(lot, lj, nTotalMount, fv))
			return false;

		fv = (fv - 1) * lj.nAmount;
	}

	return true;
}

bool BetCtlManager::getWinLosPoint(const tLottery& lot, const tLotJudge& lj, int nTotalMount, float& fv)
{
	LRSettings lrs;
	{
		QMutexLocker locker(m_cfgLock);

		lrs = (*m_lrSettings);
	}

	{
		fv = 0;

		if (!lrs.getLostrate(lot, lj, nTotalMount, fv))
			return false;

		fv = (fv - 1) * lj.nAmount;
	}

	return true;
}

bool BetCtlManager::getWinLosPoint(const tLottery& lot, const tBetInfo& bi, float& fv)
{
	LRSettings lrs;
	{
		QMutexLocker locker(m_cfgLock);

		lrs = (*m_lrSettings);
	}

	{
		fv = 0;
		int nTotalMount = bi.getTotalMount();

		for (int k = 0; k < bi.ljColl.size(); ++k)
		{
			const tLotJudge& lj = bi.ljColl[k];

			float flr = 0;
			if (!lrs.getLostrate(lot, lj, nTotalMount, flr))
				return false;

			fv += (flr - 1) * lj.nAmount;
		}
	}

	return true;
}

bool BetCtlManager::getWinLosPoint(const tLottery& lot)
{
	bool bRet = false;

	LRSettings lrs;
	{
		QMutexLocker locker(m_cfgLock);

		lrs = (*m_lrSettings);
	}

	tPScoreInfoRefMap psiColl;
	if (m_pBetMgr->getWinLosPoint(&lrs, lot, psiColl))
	{
		{
			QMutexLocker locker(m_psiLock);

			for (tPScoreInfoRefMap::ConstIterator cit = psiColl.constBegin();
				cit != psiColl.constEnd(); ++cit)
			{
				const tPScoreInfo& psi = cit.value();

				if (m_psiColl.contains(psi.pid))
				{
					tPScoreInfo* psi2 = m_psiColl[psi.pid];

					psi2->fTotalScore += psi.fTotalScore;

					psi2->fAccScore += psi.fAccScore;
					psi2->fAccWScore += psi.fAccWScore;
					psi2->fAccLScore += psi.fAccLScore;
					psi2->fAccPayment += psi.fAccPayment;

					psi2->fThisScore = psi.fThisScore;
					psi2->fThisWScore = psi.fThisWScore;
					psi2->fThisLScore = psi.fThisLScore;
					psi2->fThisPayment = psi.fThisPayment;

					psi2->nAccTurnNum += psi.nAccTurnNum;
					psi2->nAccLotNum += psi.nAccLotNum;
					psi2->nAccWLotNum += psi.nAccWLotNum;
					psi2->nAccLLotNum += psi.nAccLLotNum;

					psi2->nThisLotNum = psi.nThisLotNum;
					psi2->nThisWLotNum = psi.nThisWLotNum;
					psi2->nThisLLotNum = psi.nThisLLotNum;
				}
			}
		}

		//refreshModelForPSCoreInfo();

		m_sm->doAction(GA_PSCoreDone);

		bRet = true;
	}

	return bRet;
}

QString BetCtlManager::getScoreBoard()
{
	QString strSB;
	{
		QMutexLocker locker(m_psiLock);

		for (tPScoreInfoMap::ConstIterator cit = m_psiColl.constBegin();
			cit != m_psiColl.constEnd(); ++cit)
		{
			const tPScoreInfo* psi = cit.value();

			strSB += ZN_STR("\t%1 => 总积分: ").arg(psi->strName) + QString::number(psi->fTotalScore,'f',2);
			strSB += ZN_STR(", 本轮总分: ") + QString::number(psi->fThisScore, 'f', 2) + "\n";
		}
	}

	return strSB;
}

void BetCtlManager::resetNeeded()
{
	{
		QMutexLocker locker(m_psiLock);

		for (tPScoreInfoMap::iterator it = m_psiColl.begin();
			it != m_psiColl.end(); ++it)
		{
			tPScoreInfo* psi = it.value();

			psi->resetNeeded();
		}
	}

	m_pBetMgr->clearAll();
}

bool BetCtlManager::getConnected()
{
	if (m_betRbt)
		return m_betRbt->getConnected();

	return false;
}
bool BetCtlManager::getConnected() const
{
	if (m_betRbt)
		return m_betRbt->getConnected();

	return false;
}

void BetCtlManager::disconnect()
{
	if (m_betRbt)
		m_betRbt->disconnect();
}

void BetCtlManager::setGStatus(GStatus gs)
{
	m_sm->setGStatus(gs);
}

bool BetCtlManager::isCountdownExpired(int gs)
{
	bool bRet = false;

	if (GS_openbet == gs || GS_closebet == gs || GS_waitfordrawlot == gs)
	{
		int secs = -1;
		QString strDat;
		if (caculateWaitLotterySecondsLeft(0, secs, strDat))
		{
			Q_EMIT dispDrawLotteryTimeLeft(strDat);

			if (GS_waitfordrawlot == gs && secs <= 30)
			{
				bRet = true;
			}
		}
	}

	return bRet;
}

void BetCtlManager::doMessageQueueSend()
{
	QByteArray ba;
	if (takeMsg(ba))
	{
		if (m_betRbt)
			m_betRbt->sendMsg(ba);
	}
}

void BetCtlManager::doAction(int gs)
{
	if (GS_idle == gs)
	{

	}
	else if (GS_init == gs)
	{
		if (m_betRbt)
		{
			const tLoginParam& lp = m_loginParam;

			m_betRbt->setParams(lp.strHost, lp.nPort);
			m_betRbt->setUserNameAndPassword(lp.strUser, lp.strPass);

			QObject::connect(m_betRbt, SIGNAL(connectedStateChanged(const QString&, bool)), this, SLOT(connectedStateChanged(const QString&, bool)));
			QObject::connect(m_betRbt, SIGNAL(stateChanged(quint32, qint32)), this, SLOT(stateChanged(quint32, qint32)));
		}

		if (m_pb)
		{
			QObject::connect(m_pb, SIGNAL(playerEnter(const tPlayer&)), this, SLOT(playerEnter(const tPlayer&)));
			QObject::connect(m_pb, SIGNAL(playerLeave(const QString&)), this, SLOT(playerLeave(const QString&)));
			QObject::connect(m_pb, SIGNAL(playersClear()), this, SLOT(playersClear()));

			QObject::connect(m_pb, SIGNAL(playerState(const QString&,int,int)), this, SLOT(playerState(const QString&, int, int)));
			QObject::connect(m_pb, SIGNAL(setPlayerList(const tPlayerRefMap&,int)), this, SLOT(setPlayerList(const tPlayerRefMap&, int)));

			QObject::connect(m_pb, SIGNAL(dispTalkMsg(const QString&, const QString&)), this, SLOT(dispTalkMsg(const QString&, const QString&)));
			QObject::connect(m_pb, SIGNAL(dispSysTalkMsg(const QString&, const QString&)), this, SLOT(dispSysTalkMsg(const QString&, const QString&)));

			/*QObject::connect(m_pb, SIGNAL(setLotteryState(int, int)), this, SLOT(setLotteryState(int, int)));
			QObject::connect(m_pb, SIGNAL(setLotteryServerTime(const tServerTime&)), this, SLOT(setLotteryServerTime(const tServerTime&)));
			QObject::connect(m_pb, SIGNAL(setLotteryHistory(const tLotteryRefMap&)), this, SLOT(setLotteryHistory(const tLotteryRefMap&)));
			QObject::connect(m_pb, SIGNAL(setLotteryNext(const tLottery&)), this, SLOT(setLotteryNext(const tLottery&)));
			QObject::connect(m_pb, SIGNAL(setLotteryLatest(const tLottery&)), this, SLOT(setLotteryLatest(const tLottery&)));*/
		}
	}
	else if (GS_connecting == gs)
	{
		//m_betRbt->reconnectToHost();
	}
	else if (GS_connected == gs)
	{
		
	}
	else if (GS_logining == gs)
	{
		//if (m_betRbt)
			//m_betRbt->doLoginMsg();
	}
	else if (GS_logined == gs)
	{
		
	}
	else if (GS_fetchplayerlist == gs)
	{
		if (m_betRbt)
			m_betRbt->doPlayerReqMsg(2);
	}
	else if (GS_fetchservertime == gs)
	{
		lotteryRequest(0);
	}
	else if (GS_fetchlothistory == gs)
	{
		lotteryRequest(1);
	}
	else if (GS_curlotperiods == gs)
	{
		Q_EMIT dispDrawLotteryTimeLeft(ZN_STR("-"));

		lotteryRequest(2);
	}
	else if (GS_openbet == gs)
	{
		sysTalkMsg(ZN_STR("第%1期 开盘开始下注").arg(m_nNextPeriods));

		m_bBetStartup = true;
	}
	else if (GS_waitfordrawlot == gs)
	{
		
	}
	else if (GS_closebet == gs)
	{
		sysTalkMsg(ZN_STR("第%1期 封盘停止下注").arg(m_nNextPeriods));

		m_bBetStartup = false;

		{
#define MAX_BETBIL_NUM		100

			tBetInfoMap bicoll;
			m_pBetMgr->getBetInfoMap(bicoll);

			QString strBetBill;
			int kk = 0;
			int ind = 0;
			int tind = bicoll.size() / MAX_BETBIL_NUM;
			if ((bicoll.size() % MAX_BETBIL_NUM) != 0)
				++tind;

			tBetInfoMap::iterator it = bicoll.begin();
				
			while(!m_bQuit)
			{
				if (it != bicoll.end())
				{
					tBetInfo& bi = it.value();
					strBetBill += bi.getBetBill();

					++it;
					++kk;
				}

				if ( kk >= MAX_BETBIL_NUM || it == bicoll.end())
				{
					if (strBetBill.isEmpty())
						strBetBill = ZN_STR("无\n");

					strBetBill = ZN_STR("第%1期 投注清单[%2/%3]:\n").arg(m_nNextPeriods).arg(ind).arg(tind) + strBetBill;
					sysTalkMsg(strBetBill);

					strBetBill.clear();

					kk = 0;
					++ind;
				}

				if (it == bicoll.end())
					break;
			}
		}
	}
	else if (GS_fetchlatestlot == gs)
	{
		//lotteryRequest(1);
	}
	else if (GS_calculot == gs)
	{
		Q_EMIT dispDrawLotteryTimeLeft(ZN_STR("-"));

		sysTalkMsg(ZN_STR("第%1期 开奖号码: %2").arg(m_nNextPeriods).arg(m_curlot.asAllResult()));

		getWinLosPoint(m_curlot);

		{
#define MAX_SCOREBOARD_NUM		100

			tPScoreInfoRefMap psicoll;
			{
				tBetInfoMap bicoll;
				{
					m_pBetMgr->getBetInfoMap(bicoll);
				}

				QMutexLocker locker(m_psiLock);

				for (tPScoreInfoMap::ConstIterator cit = m_psiColl.constBegin();
					cit != m_psiColl.constEnd(); ++cit)
				{
					const tPScoreInfo* psi = cit.value();

					if (bicoll.contains(psi->pid))
					{
						tPScoreInfo p(*psi);
						psicoll[psi->pid] = p;
					}
				}
			}

			QString strSB;

			int kk = 0;
			int ind = 0;
			int tind = psicoll.size() / MAX_SCOREBOARD_NUM;
			if ((psicoll.size() % MAX_SCOREBOARD_NUM) != 0)
				++tind;

			tPScoreInfoRefMap::iterator it = psicoll.begin();

			while (!m_bQuit)
			{
				if (it != psicoll.end())
				{
					tPScoreInfo& psi = it.value();

					strSB += ZN_STR("\t%1 => 总积分: ").arg(psi.strName) + QString::number(psi.fTotalScore, 'f', 2);
					strSB += ZN_STR(", 本轮总分: ") + QString::number(psi.fThisScore, 'f', 2) + "\n";

					++it;
					++kk;
				}

				if (kk >= MAX_BETBIL_NUM || it == psicoll.end())
				{
					if (strSB.isEmpty())
						strSB = ZN_STR("无\n");

					strSB = ZN_STR("第%1期 积分榜[%2/%3]:\n").arg(m_nNextPeriods).arg(ind).arg(tind) + strSB;
					sysTalkMsg(strSB);

					strSB.clear();

					kk = 0;
					++ind;
				}

				if (it == psicoll.end())
					break;
			}
		}

		resetNeeded();

		refreshModelForPSCoreInfo();
	}
	else if (GS_disconnecting == gs)
	{
		disconnect();
	}
	else if (GS_disconnected == gs)
	{
		
	}
}

void BetCtlManager::doTaskLoop()
{
#define EXEC_CMD(b,t,secs)		{ b = true; t.restart(); nMSecs = secs*1000; }
#define EXPIRE_CMDEXEC_MSECS	30000
#define EXPIRE_DRAWLOT_SECS		15

#define CMD_GAP_MSECS			5000

	bool bExecCmd = false;
	QTime st;
	st.start();

	bool bNeedSleep = false;

	int nMSecs = EXPIRE_CMDEXEC_MSECS;
	int latestSecs = 0;
	int expireLatestSecs = EXPIRE_DRAWLOT_SECS;

	int secsOld = 0;

	GStatus gs = GS_idle;

	if(!m_betRbt)
		m_betRbt = new ABetRobot();

	if(!m_pb)
		m_pb = new Packet();

	while (!m_bQuit)
	{
		doMessageQueueSend();
		doBet(500);

		if (bExecCmd)
		{
			if (gs != m_sm->getGStatus())
			{
				qDebug() << "status transfer";

				bExecCmd = false;
			}

			{
				int diff = nMSecs - st.elapsed();
				if (diff > 0)
				{
					int secs = diff / 1000;

					if (GS_openbet == gs)
					{
						QString strMsg = ZN_STR("开盘倒计时...还剩 %1 秒").arg(secs);
						Q_EMIT statusMsgHint(1, strMsg);

						if ((secs % 5) == 0 && secsOld != secs)
						{
							sysTalkMsg(strMsg);

							secsOld = secs;
						}

						isCountdownExpired(gs);
					}
					else if (GS_closebet == gs)
					{
						QString strMsg = ZN_STR("封盘倒计时...还剩 %1 秒").arg(secs);
						Q_EMIT statusMsgHint(1, strMsg);

						if ((secs % 5) == 0 && secsOld != secs)
						{
							sysTalkMsg(strMsg);

							secsOld = secs;
						}

						isCountdownExpired(gs);
					}
				}
				else
				{
					qDebug() << "exec cmd timedout";

					if (GS_openbet == gs)
					{
						doAction(GS_openbet);

						m_sm->doAction(GA_OpenBetDone);
					}
					else if (GS_closebet == gs)
					{
						doAction(GS_closebet);

						latestSecs = 0;
						expireLatestSecs = EXPIRE_DRAWLOT_SECS;
						st.restart();

						m_sm->doAction(GA_CloseBetDone);
					}

					bExecCmd = false;
				}
			}

			bNeedSleep = true;

			QCoreApplication::processEvents();

			continue;
		}

		gs = m_sm->getGStatus();

		updateSMInfo(gs);

		if (GS_idle == gs)
		{
			bNeedSleep = true;
		}
		else if (GS_init == gs)
		{
			doAction(gs);
			
			if (m_betRbt)
				m_betRbt->reconnectToHost();

			m_sm->doAction(GA_InitedDone);
		}
		else if (GS_connecting == gs)
		{
			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_connected == gs)
		{
			if (m_betRbt)
				m_betRbt->doLoginMsg();

			m_sm->doAction(GA_ConnectedDone);
		}
		else if (GS_logining == gs)
		{
			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_logined == gs)
		{
			m_sm->doAction(GA_LoginedDone);
		}
		else if (GS_fetchplayerlist == gs)
		{
			doAction(gs);

			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_fetchservertime == gs)
		{
			doAction(gs);

			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_fetchlothistory == gs)
		{
			doAction(gs);

			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_curlotperiods == gs)
		{
			doAction(gs);

			EXEC_CMD(bExecCmd, st, 10);
		}
		else if (GS_openbet == gs)
		{
			EXEC_CMD(bExecCmd, st, 10);
		}
		else if (GS_waitfordrawlot == gs)
		{
			if (isCountdownExpired(gs))
			{
				m_sm->doAction(GA_WaitForDrawLotDone);
			}

			bNeedSleep = true;
		}
		else if (GS_closebet == gs)
		{
			EXEC_CMD(bExecCmd, st, 30);
		}
		else if (GS_fetchlatestlot == gs)
		{
			int secs = st.elapsed() / 1000;
			QString strDat = getTimeLeftString(1, secs);

			if (secs - latestSecs > expireLatestSecs)
			{
				latestSecs = secs;
				expireLatestSecs = 10;

				lotteryRequest(3);
			}

			Q_EMIT dispDrawLotteryTimeLeft(strDat);

			bNeedSleep = true;
		}
		else if (GS_calculot == gs)
		{
			doAction(gs);

			m_sm->doAction(GA_PSCoreDone);
		}
		else if (GS_disconnecting == gs)
		{
			doAction(gs);

			m_sm->doAction(GA_DisconnectingDone);
		}
		else if (GS_disconnected == gs)
		{
			m_sm->doAction(GA_DisconnectedDone);
		}
		
		QCoreApplication::processEvents();
	}

	delete m_betRbt;
}

void BetCtlManager::talkMsg(const QString& strMsg)
{
	if (m_betRbt)
	{
		QString pid = m_betRbt->getPId();

		QByteArray ba;
		if (Packet::packTalkMsg(ba, pid, 1, strMsg))
		{
			m_betRbt->sendMsg(ba);
		}
	}
}

void BetCtlManager::sysTalkMsg(const QString& strMsg)
{
	if (m_betRbt)
	{
		QString pid = m_betRbt->getPId();

		QByteArray ba;
		if (Packet::packSysTalkMsg(ba, pid, 3, strMsg))
		{
			m_betRbt->sendMsg(ba);

			Q_EMIT dispTalkMsg(pid, m_loginParam.strUser, strMsg, 1);
		}
	}
}

void BetCtlManager::talkMsgInQueue(const QString& strMsg)
{
	if (m_betRbt)
	{
		QString pid = m_betRbt->getPId();

		QByteArray ba;
		if (Packet::packTalkMsg(ba, pid, 1, strMsg))
		{
			putMsg(ba);
		}
	}
}

void BetCtlManager::sysTalkMsgInQueue(const QString& strMsg)
{
	if (m_betRbt)
	{
		QString pid = m_betRbt->getPId();

		QByteArray ba;
		if (Packet::packSysTalkMsg(ba, pid, 3, strMsg))
		{
			putMsg(ba);
		}
	}
}

void BetCtlManager::lotteryRequest(int type)
{
	if (m_lqgClient)
	{
		m_lqgClient->fetchLotteryInfo(type);
	}
}

void BetCtlManager::putReceivedMsgToQueue(const QString& pid, const QString& strName, const QString& strContent, int flag)
{
	{
		tBetMsg msg;
		msg.pid = pid;
		msg.strName = strName;
		msg.strContent = strContent;
		msg.flag = flag;

		QMutexLocker locker(m_bmLock);
		m_bmColl.append(msg);
	}
}

bool BetCtlManager::doBet(const QString& strBetStr, const QString& pid, const QString& strName)
{
	QString strMsg;

	tLotJudgeVector ljcoll;

	float fScore = 0;
	if (getPScoreInfoForTotalScore(pid, fScore))
	{
	}

	int nScore = fScore;
	int mnt = m_pBetMgr->getTotalMount(pid);

	//Q_EMIT dispTalkMsg(pid, strName, strBetStr, 0);

	QStringList strlst = strBetStr.split(' ', Qt::SkipEmptyParts);

	for (int k = 0; k < strlst.size(); ++k)
	{
		QString& strSubBetStr = strlst[k];

		tLotJudge lj;
		{
			if (!lj.addBetInfo(pid, strName, strSubBetStr))
			{
				sysTalkMsg(ZN_STR("用户 %1 投注无效,不能识别: %2").arg(strName).arg(strBetStr));
				return false;
			}

			if (!checkRules(lj, strMsg))
			{
				sysTalkMsg(ZN_STR("用户 %1 投注无效,违反规则: %2").arg(strName).arg(strMsg));
				return false;
			}

			mnt += lj.nAmount;

			if (mnt > nScore)
			{
				sysTalkMsg(ZN_STR("用户 %1 投注无效,余额不足: %2 < %3").arg(strName).arg(nScore).arg(mnt));
				return false;
			}
		}

		ljcoll.append(lj);
	}

	strMsg = "";
	for (int i = 0; i < ljcoll.size(); ++i)
	{
		tLotJudge& lj = ljcoll[i];

		m_pBetMgr->addBetJudge(lj);

		if (!strMsg.isEmpty())
			strMsg += ",";
		strMsg += lj.asString();
	}

	sysTalkMsg(ZN_STR("用户 %1 投注有效: %2").arg(strName).arg(strMsg));

	//if (setPScoreInfoForBetString(pid, strBetStr))
	//{
	//	//refreshModelForPSCoreInfo();
	//}

	return true;
}

bool BetCtlManager::doBet(const tBetMsg& bm)
{
	const int& flag = bm.flag;

	if (1 == flag || 0 == flag)
	{
		return doBet(bm.strContent, bm.pid, bm.strName);
	}

	return true;
}

void BetCtlManager::doBet(int msecs)
{
	QMutexLocker locker(m_bmLock);

	QElapsedTimer t;
	t.start();

	int cnt = 0;

	qint64 ms = t.elapsed();
	while (ms < msecs && !m_bmColl.isEmpty())
	{
		tBetMsg& bm = m_bmColl[0];

		doBet(bm);
		m_bmColl.pop_front();

		++cnt;

		ms = t.elapsed();
	}

	//if(cnt > 0 || m_bmColl.size() > 0)
		//qDebug() << "BetCtlManager::doBet: cnt = " << cnt << ", m_bmColl.size = " << m_bmColl.size() << ",ms = " << ms;
}

void BetCtlManager::playerEnter(const tPlayer& p)
{
	if (!isExistPScoreInfo(p.pid))
	{
		tPScoreInfo* psi = new tPScoreInfo();
		{
			psi->pid = p.pid;
			psi->strName = p.strName;
			psi->nType = p.type;
#ifdef _DEBUG
			psi->fTotalScore = 100000;
#else
			psi->fTotalScore = 100000;
#endif
		}

		appendPScoreInfo(psi);

		refreshModelForPSCoreInfo();
	}

	appendPlayer(p);
}

void BetCtlManager::playerLeave(const QString& pid)
{
	removePScoreInfo(pid);

	refreshModelForPSCoreInfo();

	removePlayer(pid);
}

void BetCtlManager::playersClear()
{
	clearAllPScoreInfo();

	refreshModelForPSCoreInfo();

	clearAllPlayers();
}

void BetCtlManager::playerState(const QString& pid, int type, int code)
{
	if (0 == type)
	{
		if (0 == code)
		{
			if(m_betRbt)
				m_betRbt->setPId(pid);

			m_sm->doAction(GA_LoginingDone);

			QString strMsg = ZN_STR("当前用户: %1").arg(pid);
			Q_EMIT statusMsgHint(0, strMsg);
		}
	}
}

void BetCtlManager::setPlayerList(const tPlayerRefMap& prColl, int type)
{
	for (tPlayerRefMap::ConstIterator cit = prColl.cbegin();
		cit != prColl.cend(); ++cit)
	{
		const tPlayer& p = cit.value();

		if (!isExistPScoreInfo(p.pid))
		{
			tPScoreInfo* psi = new tPScoreInfo();
			{
				psi->pid = p.pid;
				psi->strName = p.strName;
				psi->nType = p.type;
				psi->fTotalScore = 100000;
			}

			appendPScoreInfo(psi);
		}

		appendPlayer(p);
	}

	refreshModelForPSCoreInfo();

	m_sm->doAction(GS_fetchplayerlistDone);
}

void BetCtlManager::dispTalkMsg(const QString& pid, const QString& strMsg)
{
	Q_EMIT dispTalkMsg(pid, pid, strMsg, 0);

	if (m_bBetStartup)
	{
		tPlayer p;
		if (getPlayerInfo(pid, p))
		{
			putReceivedMsgToQueue(pid, p.strName, strMsg, 0);
		}
	}
}

void BetCtlManager::dispSysTalkMsg(const QString& pid, const QString& strMsg)
{
	Q_EMIT dispTalkMsg(pid, pid, strMsg, 1);
}

void BetCtlManager::setLotteryState(int type, int code)
{
	updateStatusInfo(type, code);
}

void BetCtlManager::setLotteryServerTime(const tServerTime& st)
{
	QDateTime dt = QDateTime::currentDateTime();
	m_dtDelta = st.dtServerTime.toTime_t() - dt.toTime_t();

	//QString str = p.dtServerTime.toString("yyyy-MM-dd hh:mm:ss");
	//qDebug() << "ServerTime = " << str;

	m_sm->doAction(GA_ServerTimeDone);
}

void BetCtlManager::setLotteryHistory(const tLotteryRefMap& coll)
{
	for (tLotteryRefMap::ConstIterator cit = coll.cbegin();
		cit != coll.cend(); ++cit)
	{
		const tLottery& p = cit.value();

		if (!isExistLottery(p.nPeriods))
		{
			tLottery* lot = new tLottery();
			{
				(*lot) = p;
			}

			appendLottery(lot);
		}
	}

	refreshModelForLotteryInfo();

	m_sm->doAction(GA_FetchLotHistoryDone);
}

void BetCtlManager::setLotteryNext(const tLottery& lot)
{
	//qDebug() << "setCurrentPeriods: nPeriods = " << lot.nPeriods << ", BeginTime = " << lot.strBeginTime << ", OpenTime = " << lot.strOpenTime;

	if (lot.nPeriods >= m_nNextPeriods)
	{
		m_nNextPeriods = lot.nPeriods;
		m_dtNextPeriods = lot.dtBeginTime.toTime_t();

		updateStatusInfo(2, 0);

		Q_EMIT dispALottery(0, lot);

		m_sm->doAction(GA_CurrentPeriodsDone);
	}
	else
	{
		qDebug() << "setCurrentPeriods: lot.nPeriods = " << lot.nPeriods << ", m_nNextPeriods = " << m_nNextPeriods;
	}
}

void BetCtlManager::setLotteryLatest(const tLottery& lot)
{
	if (lot.nPeriods >= m_nNextPeriods)
	{
		if (0 == m_nNextPeriods)
		{
			m_nNextPeriods = lot.nPeriods + 1;
			m_dtNextPeriods = lot.dtBeginTime.toTime_t();

			tLottery lot2 = lot;
			lot2.nPeriods = m_nNextPeriods;
			Q_EMIT dispALottery(0, lot2);
		}

		Q_EMIT dispALottery(1, lot);

		{
			bool bDispLotteryList = false;
			{
				QMutexLocker locker(m_lotLock);

				if (!m_lotColl.contains(lot.nPeriods))
				{
					tLottery* pp = new tLottery(lot);
					m_lotColl[lot.nPeriods] = pp;
					bDispLotteryList = true;
				}
			}

			if (bDispLotteryList)
			{
				refreshModelForLotteryInfo();
			}

			m_curlot = lot;

			m_sm->doAction(GA_FetchLatestLotDone);
		}
	}
}

void BetCtlManager::connectedStateChanged(const QString& pid, bool bConnected)
{
	if (bConnected)
	{
		m_sm->doAction(GA_ConnectingDone);
	}
	else
	{
		m_sm->doAction(GA_DisconnectingDone);
	}
}

void BetCtlManager::stateChanged(quint32 msgId, qint32 code)
{
	if (0 == msgId && 0 == code)
	{
		m_sm->doAction(GA_LoginedDone);
	}
}

void BetCtlManager::onClearAll()
{
	{
		clearAllPScoreInfo();
		refreshModelForPSCoreInfo();
	}

	{
		clearAllLotterys();
		refreshModelForLotteryInfo();
	}
}

static QString getAttrString(const XMLElement* pEle, const QString& strName)
{
	QString str;

	const char* ss = pEle->Attribute(strName.toLocal8Bit());
	if (ss)
		str = ss;

	return str;
}

static int getAttrInt(const XMLElement* pEle, const QString& strName)
{
	QString str = getAttrString(pEle,strName);

	return str.toInt();
}

static float getAttrFloat(const XMLElement* pEle, const QString& strName)
{
	QString str = getAttrString(pEle, strName);

	return str.toFloat();
}

static double getAttrDouble(const XMLElement* pEle, const QString& strName)
{
	QString str = getAttrString(pEle, strName);

	return str.toDouble();
}

static bool getAttrBool(const XMLElement* pEle, const QString& strName)
{
	QString str = getAttrString(pEle, strName);
	{
		str = str.toLower();
	}

	if (str == "0" || str == "false")
		return false;

	return true;
}

static bool setAttribute(XMLElement* pEle, const QString& strName, const QString& strValue)
{
	pEle->SetAttribute(strName.toLocal8Bit(), strValue.toLocal8Bit().data());
	
	return true;
}

static bool setAttribute(XMLElement* pEle, const QString& strName, int val)
{
	pEle->SetAttribute(strName.toLocal8Bit(), val);

	return true;
}

static bool setAttribute(XMLElement* pEle, const QString& strName, float fv)
{
	pEle->SetAttribute(strName.toLocal8Bit(), fv);

	return true;
}

static bool setAttribute(XMLElement* pEle, const QString& strName, double dv)
{
	pEle->SetAttribute(strName.toLocal8Bit(), dv);

	return true;
}

static bool setAttribute(XMLElement* pEle, const QString& strName, bool b)
{
	pEle->SetAttribute(strName.toLocal8Bit(), b);

	return true;
}

static bool getGross1314LRDefs(const XMLElement* pEle, tGrossAnd1314LRDefVector& coll)
{
	const XMLElement *pG1314LR = pEle->FirstChildElement("Gross1314LRDefs");
	if (pG1314LR)
	{
		coll.clear();

		const XMLElement *pItem = pG1314LR->FirstChildElement("item");
		while (pItem)
		{
			{
				tGrossAnd1314LRDef def;
				def.bUseThis = getAttrBool(pItem, ZN_STR("UseThis"));
				def.nGross = getAttrInt(pItem, ZN_STR("Gross"));
				def.fTimes = getAttrFloat(pItem, ZN_STR("Times"));

				coll.append(def);
			}

			pItem = pItem->NextSiblingElement();
		}
	}

	return true;
}

static bool getLikeCardLRDefs(const XMLElement* pEle, tLikeCardLRDefVector& coll)
{
	const XMLElement *pLikeCardLR = pEle->FirstChildElement("LikeCardLRDefs");
	if (pLikeCardLR)
	{
		coll.clear();

		const XMLElement *pItem = pLikeCardLR->FirstChildElement("item");
		while (pItem)
		{
			{
				tLikeCardLRDef def;
				def.bUseThis = getAttrBool(pItem, ZN_STR("UseThis"));
				def.nType = getAttrInt(pItem, ZN_STR("Type"));
				def.fTimes = getAttrFloat(pItem, ZN_STR("Times"));

				coll.append(def);
			}

			pItem = pItem->NextSiblingElement();
		}
	}

	return true;
}

static XMLElement* newXmlElement(XMLDocument& doc, const QString& strName)
{
	XMLElement* pEle = doc.NewElement(strName.toLocal8Bit());
	XMLNode* pNode = doc.InsertEndChild(pEle);
	if (pNode)
		pEle = pNode->ToElement();

	return pEle;
}

static XMLElement* newXmlElement(XMLDocument& doc, XMLElement* parent, const QString& strName)
{
	XMLElement* pEle = doc.NewElement(strName.toLocal8Bit());
	XMLNode* pNode = parent->InsertEndChild(pEle);
	if (pNode)
		pEle = pNode->ToElement();

	return pEle;
}

static bool setGross1314LRDefs(XMLDocument& doc, XMLElement* pEle, const tGrossAnd1314LRDefVector& coll)
{
	XMLElement *pG1314LR = pEle->FirstChildElement("Gross1314LRDefs");
	if (!pG1314LR)
		pG1314LR = newXmlElement(doc, pEle, "Gross1314LRDefs");

	if (pG1314LR)
	{
		pG1314LR->DeleteChildren();

		for (int k = 0; k < coll.size(); ++k)
		{
			XMLElement *pItem = newXmlElement(doc, pG1314LR, "item");
			if (pItem)
			{
				const tGrossAnd1314LRDef& def = coll[k];

				setAttribute(pItem, ZN_STR("UseThis"), def.bUseThis);
				setAttribute(pItem, ZN_STR("Gross"), def.nGross);
				setAttribute(pItem, ZN_STR("Times"), def.fTimes);
			}
		}
	}

	return true;
}

static bool setLikeCardLRDefs(XMLDocument& doc, XMLElement* pEle, const tLikeCardLRDefVector& coll)
{
	XMLElement *pLikeCardLR = pEle->FirstChildElement("LikeCardLRDefs");
	if (!pLikeCardLR)
		pLikeCardLR = newXmlElement(doc, "LikeCardLRDefs");

	if (pLikeCardLR)
	{
		pLikeCardLR->DeleteChildren();

		for (tLikeCardLRDefVector::ConstIterator cit = coll.constBegin();
			cit != coll.constEnd(); ++cit)
		{
			XMLElement *pItem = newXmlElement(doc, pLikeCardLR, "item");
			if (pItem)
			{
				const tLikeCardLRDef& def = (*cit);

				setAttribute(pItem, ZN_STR("UseThis"), def.bUseThis);
				setAttribute(pItem, ZN_STR("Type"), def.nType);
				setAttribute(pItem, ZN_STR("Times"), def.fTimes);
			}
		}
	}

	return true;
}

static bool getLotteryQuota(const XMLElement* pEle, tQuotaVector& coll)
{
	if (pEle)
	{
		coll.clear();

		const XMLElement *pItem = pEle->FirstChildElement("item");
		while (pItem)
		{
			{
				tQuota q;
				q.bUseThis = getAttrBool(pItem, ZN_STR("UseThis"));
				q.nAmount = getAttrInt(pItem, ZN_STR("Amount"));
				q.nType = getAttrInt(pItem, ZN_STR("Type"));

				coll.append(q);
			}

			pItem = pItem->NextSiblingElement();
		}
	}

	return true;
}

static bool getLotteryForbid(const XMLElement* pEle, tForbidVector& coll)
{
	if (pEle)
	{
		coll.clear();

		const XMLElement *pItem = pEle->FirstChildElement("item");
		while (pItem)
		{
			{
				tForbid f;
				f.bUseForbid = getAttrBool(pItem, ZN_STR("UseForbid"));
				f.bUseThis = getAttrBool(pItem, ZN_STR("UseThis"));
				f.nAmount = getAttrInt(pItem, ZN_STR("Amount"));
				f.nType = getAttrInt(pItem, ZN_STR("Type"));

				coll.append(f);
			}

			pItem = pItem->NextSiblingElement();
		}
	}

	return true;
}

static bool setLotteryQuota(XMLDocument& doc, XMLElement* pEle, const tQuotaVector& coll)
{
	if (pEle)
	{
		pEle->DeleteChildren();

		for (int k = 0; k < coll.size(); ++k)
		{
			XMLElement *pItem = newXmlElement(doc, pEle, "item");
			if (pItem)
			{
				const tQuota& q = coll[k];

				setAttribute(pItem, ZN_STR("UseThis"), q.bUseThis);
				setAttribute(pItem, ZN_STR("Amount"), q.nAmount);
				setAttribute(pItem, ZN_STR("Type"), q.nType);
			}
		}
	}

	return true;
}

static bool setLotteryForbid(XMLDocument& doc, XMLElement* pEle, const tForbidVector& coll)
{
	if (pEle)
	{
		pEle->DeleteChildren();

		for (int k = 0; k < coll.size(); ++k)
		{
			XMLElement *pItem = newXmlElement(doc, pEle, "item");
			if (pItem)
			{
				const tForbid& f = coll[k];

				setAttribute(pItem, ZN_STR("UseForbid"), f.bUseForbid);
				setAttribute(pItem, ZN_STR("UseThis"), f.bUseThis);
				setAttribute(pItem, ZN_STR("Amount"), f.nAmount);
				setAttribute(pItem, ZN_STR("Type"), f.nType);
			}
		}
	}

	return true;
}

bool BetCtlManager::loadConfigFromFile(const QString& strXmlFilePath)
{
	XMLDocument doc;
	if (XML_SUCCESS != doc.LoadFile(strXmlFilePath.toLocal8Bit().data()))
		return false;

	XMLElement *pConfig = doc.RootElement();
	if (pConfig)
	{
		QString str;

		{
			XMLElement *pLR = pConfig->FirstChildElement("lostrate");
			if (pLR)
			{
				LRSettings* lrs = m_lrSettings;

				{
					XMLElement *pSDLR = pLR->FirstChildElement("sdlr");
					if (pSDLR)
					{
						SumDigitalLR& sdlr = lrs->getSumDigitalLR();

						sdlr.m_bUseAccordLR = getAttrBool(pSDLR, ZN_STR("UseAccordLR"));
						sdlr.m_fAccordLR = getAttrFloat(pSDLR, ZN_STR("AccordLR"));

						str = getAttrString(pSDLR, ZN_STR("SingleLR"));
						if (!sdlr.setLRString(str))
							return false;
					}
				}

				{
					XMLElement *pBSOELR = pLR->FirstChildElement("bsoelr");
					if (pBSOELR)
					{
						BigSmallAndOddEvenLR& bsoelr = lrs->getBigSmallAndOddEvenLR();

						bsoelr.m_fAccordLR = getAttrFloat(pBSOELR, ZN_STR("AccordLR"));

						getGross1314LRDefs(pBSOELR, bsoelr.m_g1314Coll);
						getLikeCardLRDefs(pBSOELR, bsoelr.m_lcColl);
					}
				}

				{
					XMLElement *pGrpLR = pLR->FirstChildElement("grplr");
					if (pGrpLR)
					{
						GroupByLR& grplr = lrs->getGroupByLR();

						grplr.m_bUseAlg1 = getAttrBool(pGrpLR, ZN_STR("UseAlg1"));
						grplr.m_fAccordLR = getAttrFloat(pGrpLR, ZN_STR("AccordLR"));
						grplr.m_bUse1314LR = getAttrBool(pGrpLR, ZN_STR("Use1314LR"));
						grplr.m_f1314LR = getAttrFloat(pGrpLR, ZN_STR("Sum1314LR"));
						grplr.m_fBigEvenAndSmallOddLR = getAttrFloat(pGrpLR, ZN_STR("BESOLR"));
						grplr.m_fSmallEvenAndBigOddLR = getAttrFloat(pGrpLR, ZN_STR("SEBOLR"));

						getGross1314LRDefs(pGrpLR, grplr.m_g1314Coll);
						getLikeCardLRDefs(pGrpLR, grplr.m_lcColl);
					}
				}

				{
					XMLElement *pMMLR = pLR->FirstChildElement("mmlr");
					if (pMMLR)
					{
						MinMaxByLR& mmlr = lrs->getMinMaxByLR();

						mmlr.m_fAccordLR = getAttrFloat(pMMLR, ZN_STR("AccordLR"));
					}
				}

				{
					XMLElement *pLCLR = pLR->FirstChildElement("lclr");
					if (pLCLR)
					{
						LikeCardLR& lclr = lrs->getLikeCardLR();

						lclr.m_bUse890 = getAttrFloat(pLCLR, ZN_STR("Use890"));

						getLikeCardLRDefs(pLCLR, lclr.m_lcColl);
					}
				}
			}
		}

		{
			XMLElement *pLotRule = pConfig->FirstChildElement("lotrule");
			if (pLotRule)
			{
				LotteryRule* lr = m_lotRule;

				lr->setSDLimit( getAttrBool(pLotRule, ZN_STR("UseSDLimit")) );
				lr->setMaxSDDiffNum( getAttrFloat(pLotRule, ZN_STR("MaxSDDiffNum")) );
				lr->setHintInvalid( getAttrBool(pLotRule, ZN_STR("HintInvalid")) );
				lr->setSaveScreenshot( getAttrFloat(pLotRule, ZN_STR("SaveScreenshot")) );

				{
					XMLElement *pLQ = pLotRule->FirstChildElement("LotQuota");
					if (pLQ)
					{
						tLotQuota& lq = lr->getLotteryQuata();

						lq.bUseSDGross = getAttrBool(pLQ, ZN_STR("UseSDGross"));

						{
#ifdef USE_CONTAINER
							tQuotaVector coll;
							getLotteryQuota(pLQ, coll);

							lq.qcoll = coll;
#else
							tQuotaVector coll;
							getLotteryQuota(pLQ, coll);

							lq.minAllQuota = coll[0];

							lq.maxSDQuota = coll[1];

							lq.maxBSOEQuota = coll[2];
							lq.maxGrpQuota = coll[3];
							lq.maxMMQuota = coll[4];

							lq.max3SameQuota = coll[5];
							lq.max2SameQuota = coll[6];
							lq.maxContQuota = coll[7];

							lq.maxAllQuota = coll[8];
#endif
						}
					}
				}

				{
					XMLElement *pLF = pLotRule->FirstChildElement("LotForbid");
					if (pLF)
					{
						tLotForbid& lf = lr->getLotteryForbid();

						{
#ifdef USE_CONTAINER
							tForbidVector coll;
							getLotteryForbid(pLF, coll);

							lf.fcoll = coll;
#else
							tForbidVector coll;
							getLotteryForbid(pLF, coll);

							lf.killGrpForbid = coll[0];
							lf.reverseGrpForbid = coll[1];
							lf.syntropyGrpForbid = coll[2];

							lf.reverseBSOEForbid = coll[3];
#endif
						}
					}
				}
			}
		}
	}

	return true;
}

bool BetCtlManager::saveConfigFromFile(const QString& strXmlFilePath)
{
	XMLDocument doc;
	if (XML_SUCCESS != doc.LoadFile(strXmlFilePath.toLocal8Bit().data()))
	{
		XMLDeclaration* declaration = doc.NewDeclaration();
		doc.InsertFirstChild(declaration);
	}

	XMLElement *pConfig = doc.RootElement();
	if (!pConfig)
		pConfig = newXmlElement(doc, "config");
	
	if (pConfig)
	{
		QString str;

		{
			XMLElement *pLR = pConfig->FirstChildElement("lostrate");
			if (!pLR)
				pLR = newXmlElement(doc, pConfig, "lostrate");

			if (pLR)
			{
				const LRSettings* lrs = m_lrSettings;

				{
					XMLElement *pSDLR = pLR->FirstChildElement("sdlr");
					if (!pSDLR)
						pSDLR = newXmlElement(doc, pLR, "sdlr");

					if (pSDLR)
					{
						const SumDigitalLR& sdlr = lrs->getSumDigitalLR();

						setAttribute(pSDLR, ZN_STR("UseAccordLR"), sdlr.m_bUseAccordLR);
						setAttribute(pSDLR, ZN_STR("AccordLR"), sdlr.m_fAccordLR);

						setAttribute(pSDLR, ZN_STR("SingleLR"), sdlr.getLRString() );
					}
				}

				{
					XMLElement *pBSOELR = pLR->FirstChildElement("bsoelr");
					if (!pBSOELR)
						pBSOELR = newXmlElement(doc, pLR, "bsoelr");

					if (pBSOELR)
					{
						const BigSmallAndOddEvenLR& bsoelr = lrs->getBigSmallAndOddEvenLR();

						setAttribute(pBSOELR, ZN_STR("AccordLR"), bsoelr.m_fAccordLR);

						setGross1314LRDefs(doc,pBSOELR, bsoelr.m_g1314Coll);
						setLikeCardLRDefs(doc,pBSOELR, bsoelr.m_lcColl);
					}
				}

				{
					XMLElement *pGrpLR = pLR->FirstChildElement("grplr");
					if (!pGrpLR)
						pGrpLR = newXmlElement(doc, pLR, "grplr");

					if (pGrpLR)
					{
						const GroupByLR& grplr = lrs->getGroupByLR();

						setAttribute(pGrpLR, ZN_STR("UseAlg1"), grplr.m_bUseAlg1);
						setAttribute(pGrpLR, ZN_STR("AccordLR"), grplr.m_fAccordLR);
						setAttribute(pGrpLR, ZN_STR("Use1314LR"), grplr.m_bUse1314LR);
						setAttribute(pGrpLR, ZN_STR("Sum1314LR"), grplr.m_f1314LR);
						setAttribute(pGrpLR, ZN_STR("BESOLR"), grplr.m_fBigEvenAndSmallOddLR);
						setAttribute(pGrpLR, ZN_STR("SEBOLR"), grplr.m_fSmallEvenAndBigOddLR);

						setGross1314LRDefs(doc, pGrpLR, grplr.m_g1314Coll);
						setLikeCardLRDefs(doc, pGrpLR, grplr.m_lcColl);
					}
				}

				{
					XMLElement *pMMLR = pLR->FirstChildElement("mmlr");
					if (!pMMLR)
						pMMLR = newXmlElement(doc, pLR, "mmlr");

					if (pMMLR)
					{
						const MinMaxByLR& mmlr = lrs->getMinMaxByLR();

						setAttribute(pMMLR, ZN_STR("AccordLR"), mmlr.m_fAccordLR);
					}
				}

				{
					XMLElement *pLCLR = pLR->FirstChildElement("lclr");
					if (!pLCLR)
						pLCLR = newXmlElement(doc, pLR, "lclr");

					if (pLCLR)
					{
						const LikeCardLR& lclr = lrs->getLikeCardLR();

						setAttribute(pLCLR, ZN_STR("Use890"), lclr.m_bUse890);

						setLikeCardLRDefs(doc, pLCLR, lclr.m_lcColl);
					}
				}
			}
		}

		{
			XMLElement *pLotRule = pConfig->FirstChildElement("lotrule");
			if (!pLotRule)
				pLotRule = newXmlElement(doc, pConfig, "lotrule");

			if (pLotRule)
			{
				const LotteryRule* lr = m_lotRule;

				setAttribute(pLotRule, ZN_STR("UseSDLimit"), lr->getSDLimit());
				setAttribute(pLotRule, ZN_STR("MaxSDDiffNum"), lr->getMaxSDDiffNum());
				setAttribute(pLotRule, ZN_STR("HintInvalid"), lr->getHintInvalid());
				setAttribute(pLotRule, ZN_STR("SaveScreenshot"), lr->getSaveScreenshot());

				{
					XMLElement *pLQ = pLotRule->FirstChildElement("LotQuota");
					if (!pLQ)
						pLQ = newXmlElement(doc, pLotRule, "LotQuota");

					if (pLQ)
					{
						const tLotQuota& lq = lr->getLotteryQuata();

						setAttribute(pLQ, ZN_STR("UseSDGross"), lq.bUseSDGross);

						{
#ifdef USE_CONTAINER
							setLotteryQuota(doc, pLQ, lq.qcoll);
#else
							tQuotaVector coll;
							{
								coll.append(lq.minAllQuota);

								coll.append(lq.maxSDQuota);

								coll.append(lq.maxBSOEQuota);
								coll.append(lq.maxGrpQuota);
								coll.append(lq.maxMMQuota);

								coll.append(lq.max3SameQuota);
								coll.append(lq.max2SameQuota);
								coll.append(lq.maxContQuota);

								coll.append(lq.maxAllQuota);
							}
							setLotteryQuota(doc, pLQ, coll);
#endif
						}
					}
				}

				{
					XMLElement *pLF = pLotRule->FirstChildElement("LotForbid");
					if (!pLF)
						pLF = newXmlElement(doc, pLotRule, "LotForbid");

					if (pLF)
					{
						const tLotForbid& lf = lr->getLotteryForbid();

						{
#ifdef USE_CONTAINER
							setLotteryForbid(doc, pLF, lf.fcoll);
#else
							tForbidVector coll;
							{
								coll.append(lf.killGrpForbid);
								coll.append(lf.reverseGrpForbid);
								coll.append(lf.syntropyGrpForbid);

								coll.append(lf.reverseBSOEForbid);
							}
							setLotteryForbid(doc, pLF, coll);
#endif
						}
					}
				}
			}
		}
	}

	if (XML_SUCCESS != doc.SaveFile(strXmlFilePath.toLocal8Bit()))
		return false;

	return true;
}

void BetCtlManager::updateStatusInfo(qint32 type, qint32 code)
{
	if (2 == type)
	{
		QString strMsg;

		qint64 n = QDateTime::currentDateTime().toTime_t() + m_dtDelta - m_dtNextPeriods;

		if (code < 0 && n >= m_dtGap)
		{
			strMsg = ZN_STR("猜猜已停止");
		}
		else
		{
			strMsg = ZN_STR("猜猜正在进行");
		}

		strMsg = ZN_STR("当前状态: ") + strMsg;

		Q_EMIT statusMsgHint(2, strMsg);
	}
}

void BetCtlManager::updateSMInfo(int gs)
{
	QString strMsg = m_sm->getGSString(gs);

	if (!strMsg.isEmpty())
	{
		strMsg = ZN_STR("状态机: ") + strMsg;

		Q_EMIT statusMsgHint(1, strMsg);
	}
}

bool BetCtlManager::caculateWaitLotterySecondsLeft(int flag, int& secs, QString& strDat)
{
	if (m_dtNextPeriods > 0)
	{
		QDateTime dt = QDateTime::currentDateTime();

		qint64 n = dt.toTime_t() + m_dtDelta - m_dtNextPeriods;

		secs = m_dtGap - n;

		strDat = getTimeLeftString(flag, secs);

		return true;
	}

	return false;
}



