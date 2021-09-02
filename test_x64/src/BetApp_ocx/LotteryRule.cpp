#include "LotteryRule.h"

#include "gdata.h"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

bool tLotQuota::checkRules(const tLotJudge& lj, const tBetInfo& bi, int nSDNum, 
								int nSDMount, int nTotalMount, QString& strMsg)
{
	{
		tQuota& q = qcoll[0];

		if (q.bUseThis && lj.nAmount < q.nAmount)
		{
			strMsg = ZN_STR("单注下注注额%1小于单注最低注额%2").arg(lj.nAmount).arg(q.nAmount);

			return false;
		}
	}

	if (BT_SumDigital == lj.eBetType)
	{
		tQuota& q = qcoll[1];

		if (q.bUseThis)
		{
			if (bUseSDGross)
			{
				if (lj.nAmount + nSDMount > q.nAmount)
				{
					strMsg = ZN_STR("单点下注总注额%1大于单点最高总注额%2").arg(lj.nAmount + nSDMount).arg(q.nAmount);

					return false;
				}
			}
			else if (lj.nAmount > q.nAmount)
			{
				strMsg = ZN_STR("单点下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

				return false;
			}
		}
	}

	if (BT_BigSmallAndOddEven == lj.eBetType)
	{
		tQuota& q = qcoll[2];

		if (q.bUseThis && lj.nAmount > q.nAmount)
		{
			strMsg = ZN_STR("大小单双下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

			return false;
		}
	}

	if (BT_GroupBy == lj.eBetType)
	{
		tQuota& q = qcoll[3];

		if (q.bUseThis && lj.nAmount > q.nAmount)
		{
			strMsg = ZN_STR("组合下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

			return false;
		}
	}

	if (BT_MinMaxBy == lj.eBetType)
	{
		tQuota& q = qcoll[4];

		if (q.bUseThis && lj.nAmount > q.nAmount)
		{
			strMsg = ZN_STR("极大极小下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

			return false;
		}
	}

	if (BT_CardBy == lj.eBetType)
	{
		if (BST_3Same_Card == lj.eBetSubType)
		{
			tQuota& q = qcoll[5];

			if (q.bUseThis && lj.nAmount > q.nAmount)
			{
				strMsg = ZN_STR("豹子下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

				return false;
			}
		}
		else if (BST_2Same_Card == lj.eBetSubType)
		{
			tQuota& q = qcoll[6];

			if (q.bUseThis && lj.nAmount > q.nAmount)
			{
				strMsg = ZN_STR("对子下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

				return false;
			}
		}
		else if (BST_Continuous_Card == lj.eBetSubType)
		{
			tQuota& q = qcoll[7];

			if (q.bUseThis && lj.nAmount > q.nAmount)
			{
				strMsg = ZN_STR("顺子下注注额%1大于单注最高注额%2").arg(lj.nAmount).arg(q.nAmount);

				return false;
			}
		}
	}

	{
		tQuota& q = qcoll[8];

		if (q.bUseThis && lj.nAmount + nTotalMount > q.nAmount)
		{
			strMsg = ZN_STR("下注总注额%1小于最高总注额%2").arg(lj.nAmount + nTotalMount).arg(q.nAmount);

			return false;
		}
	}

	return true;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

bool tLotForbid::checkRules(const tLotJudge& lj, const tBetInfo& bi, int nSDNum, 
								int nSDMount, int nTotalMount, QString& strMsg)
{
	if(BT_GroupBy == lj.eBetType)
	{
		{
			tForbid& f = fcoll[0];

			if (f.bUseForbid && (!f.bUseThis || lj.nAmount + nTotalMount <= f.nAmount))
			{
				if (bi.isKillCombined(lj, strMsg))
				{
					strMsg = ZN_STR("禁止杀组合[") + strMsg + ZN_STR("]");

					return false;
				}
			}
		}

		{
			tForbid& f = fcoll[1];

			if (f.bUseForbid && (!f.bUseThis || lj.nAmount + nTotalMount <= f.nAmount))
			{
				if (bi.isReverseCombined(lj, strMsg))
				{
					strMsg = ZN_STR("禁止反向组合[") + strMsg + ZN_STR("]");

					return false;
				}
			}
		}

		{
			tForbid& f = fcoll[2];

			if (f.bUseForbid && (!f.bUseThis || lj.nAmount + nTotalMount <= f.nAmount))
			{
				if (bi.isSyntropyCombined(lj, strMsg))
				{
					strMsg = ZN_STR("禁止同向组合[") + strMsg + ZN_STR("]");

					return false;
				}
			}
		}
	}

	if (BT_BigSmallAndOddEven == lj.eBetType)
	{
		{
			tForbid& f = fcoll[3];

			if (f.bUseForbid && (!f.bUseThis || lj.nAmount + nTotalMount <= f.nAmount))
			{
				if (bi.isReverseBigSmallAndOddEven(lj, strMsg))
				{
					strMsg = ZN_STR("禁止大小单双反向[") + strMsg + ZN_STR("]");

					return false;
				}
			}
		}
	}

	return true;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

LotteryRule::LotteryRule()
{
	toDefault();
}
LotteryRule::~LotteryRule()
{

}
LotteryRule::LotteryRule(const LotteryRule& other)
{
	LotteryRule::operator = (other);
}
const LotteryRule& LotteryRule::operator = (const LotteryRule& other)
{
	if (&other != this)
	{
		m_lotQuota = other.m_lotQuota;
		m_lotForbid = other.m_lotForbid;

		m_bUseSDLimit = other.m_bUseSDLimit;
		m_nMaxSDDiffNum = other.m_nMaxSDDiffNum;

		m_bHintInvalid = other.m_bHintInvalid;
		m_bSaveScreenshot = other.m_bSaveScreenshot;
	}

	return (*this);
}

bool LotteryRule::checkRules(const tLotJudge& lj, const tBetInfo& bi, QString& strMsg)
{
	int nSDNum = 0;
	int nSDMount = 0;
	int nTotalMount = 0;

	bi.getSDNumAndSDMountAndTotalMount(nSDNum, nSDMount, nTotalMount);

	if (!m_lotQuota.checkRules(lj,bi, nSDNum, nSDMount, nTotalMount, strMsg))
		return false;

	if (!m_lotForbid.checkRules(lj,bi, nSDNum, nSDMount, nTotalMount, strMsg))
		return false;

	if (m_bUseSDLimit && nSDNum > m_nMaxSDDiffNum)
	{
		strMsg = ZN_STR("单点数字%1大于每期最多不同点数%2").arg(nSDNum).arg(m_nMaxSDDiffNum);

		return false;
	}

	return true;
}

void LotteryRule::toDefault()
{
	{
		tLotQuota& lq =	m_lotQuota;

#ifdef USE_CONTAINER
		tQuotaVector& qcoll = lq.qcoll;

		qcoll.clear();
		qcoll.fill(tQuota(),9);

		int i = 0;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 50;

		++i;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 10000;
		lq.bUseSDGross = false;

		++i;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = false;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = false;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = false;
		qcoll[i].nAmount = 10000;

		++i;
		qcoll[i].bUseThis = true;
		qcoll[i].nAmount = 30000;
#else
		lq.minAllQuota.bUseThis = true;
		lq.minAllQuota.nAmount = 50;

		lq.maxSDQuota.bUseThis = true;
		lq.maxSDQuota.nAmount = 10000;
		lq.bUseSDGross = false;

		lq.maxBSOEQuota.bUseThis = true;
		lq.maxBSOEQuota.nAmount = 10000;

		lq.maxGrpQuota.bUseThis = true;
		lq.maxGrpQuota.nAmount = 10000;

		lq.maxMMQuota.bUseThis = true;
		lq.maxMMQuota.nAmount = 10000;

		lq.max3SameQuota.bUseThis = false;
		lq.max3SameQuota.nAmount = 10000;

		lq.max2SameQuota.bUseThis = false;
		lq.max2SameQuota.nAmount = 10000;

		lq.maxContQuota.bUseThis = false;
		lq.maxContQuota.nAmount = 10000;

		lq.maxAllQuota.bUseThis = true;
		lq.maxAllQuota.nAmount = 30000;
#endif
	}

	{
		tLotForbid& lf = m_lotForbid;

#ifdef USE_CONTAINER
		tForbidVector& fcoll = lf.fcoll;

		fcoll.clear();
		fcoll.fill(tForbid(), 4);

		int i = 0;
		fcoll[i].bUseForbid = true;
		fcoll[i].bUseThis = false;
		fcoll[i].nAmount = 30000;

		++i;
		fcoll[i].bUseForbid = true;
		fcoll[i].bUseThis = false;
		fcoll[i].nAmount = 30000;

		++i;
		fcoll[i].bUseForbid = true;
		fcoll[i].bUseThis = false;
		fcoll[i].nAmount = 30000;

		++i;
		fcoll[i].bUseForbid = false;
		fcoll[i].bUseThis = false;
		fcoll[i].nAmount = 30000;
#else
		lf.killGrpForbid.bUseForbid = true;
		lf.killGrpForbid.bUseThis = false;
		lf.killGrpForbid.nAmount = 30000;

		lf.reverseGrpForbid.bUseForbid = true;
		lf.reverseGrpForbid.bUseThis = false;
		lf.reverseGrpForbid.nAmount = 30000;

		lf.syntropyGrpForbid.bUseForbid = true;
		lf.syntropyGrpForbid.bUseThis = false;
		lf.syntropyGrpForbid.nAmount = 30000;

		lf.reverseBSOEForbid.bUseForbid = false;
		lf.reverseBSOEForbid.bUseThis = false;
		lf.reverseBSOEForbid.nAmount = 30000;
#endif
	}

	{
		m_bUseSDLimit = false;;
		m_nMaxSDDiffNum = 2;

		m_bHintInvalid = true;
		m_bSaveScreenshot = true;
	}
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



