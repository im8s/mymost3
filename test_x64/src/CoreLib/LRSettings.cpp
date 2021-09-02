#include "LRSettings.h"

#include "gdata.h"
#include "ToolFunc.h"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

SumDigitalLR::SumDigitalLR() 
	: LRBase()
{
	m_bUseAccordLR = true;

	m_fAccordLR = 2;

	m_lrColl[0] = 200;
	m_lrColl[1] = 60;
	m_lrColl[2] = 30;
	m_lrColl[3] = 20;
	m_lrColl[4] = 10;
	m_lrColl[5] = 10;
	m_lrColl[6] = 7;
	m_lrColl[7] = 5;
	m_lrColl[8] = 4;
	m_lrColl[9] = 3;
	m_lrColl[10] = 3;
	m_lrColl[11] = 3;
	m_lrColl[12] = 2;
	m_lrColl[13] = 2;
	m_lrColl[14] = 2;
	m_lrColl[15] = 2;
	m_lrColl[16] = 3;
	m_lrColl[17] = 3;
	m_lrColl[18] = 3;
	m_lrColl[19] = 4;
	m_lrColl[20] = 5;
	m_lrColl[21] = 7;
	m_lrColl[22] = 10;
	m_lrColl[23] = 10;
	m_lrColl[24] = 20;
	m_lrColl[25] = 30;
	m_lrColl[26] = 60;
	m_lrColl[27] = 200;
}
SumDigitalLR::~SumDigitalLR()
{

}
SumDigitalLR::SumDigitalLR(const SumDigitalLR& other)
{
	SumDigitalLR::operator = (other);
}
const SumDigitalLR& SumDigitalLR::operator = (const SumDigitalLR& other)
{
	if (&other != this)
	{
		m_bUseAccordLR = other.m_bUseAccordLR;

		m_fAccordLR = other.m_fAccordLR;
		m_lrColl = other.m_lrColl;
	}

	return (*this);
}

bool SumDigitalLR::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (BT_SumDigital == lj.eBetType)
	{
		if (BST_SumDigital == lj.eBetSubType)
		{
			if (lj.nSum < MIN_SD_SUM || lj.nSum > MAX_SD_SUM)
				return false;
		}
	}

	return true;
}

bool SumDigitalLR::getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr)
{
	if (BT_SumDigital == lj.eBetType && lot.isSum(lj.nSum))
	{
		if (m_bUseAccordLR)
		{
			flr = m_fAccordLR;
		}
		else
		{
			flr = m_lrColl[lj.nSum];
		}

		return true;
	}

	return false;
}

QString SumDigitalLR::getLRString()
{
	QString str;

	for (int k = 0; k < m_lrColl.size(); ++k)
	{
		str += ZN_STR("%1=%2\n").arg(k).arg(m_lrColl[k]);
	}

	return str;
}

const QString SumDigitalLR::getLRString() const
{
	QString str;

	for (int k = 0; k < m_lrColl.size(); ++k)
	{
		str += ZN_STR("%1=%2,").arg(k).arg(m_lrColl[k]);
	}

	return str;
}

bool SumDigitalLR::setLRString(const QString& str)
{
	QStringList strlst = str.split(',', Qt::SkipEmptyParts);
	if (strlst.size() != MAX_SUM_NUM)
		return false;

	m_lrColl.clear();

	for (int k = 0; k < strlst.size(); ++k)
	{
		QString str2 = strlst[k];

		QStringList strlst2 = str2.split('=', Qt::SkipEmptyParts);
		if (strlst2.size() == 2)
		{
			int key = strlst2[0].toInt();
			float val = strlst2[1].toFloat();

			if(key >= 0 && key < MAX_SUM_NUM)
				m_lrColl[key] = val;
		}
	}

	if (m_lrColl.size() != MAX_SUM_NUM)
		return false;

	return true;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

BigSmallAndOddEvenLR::BigSmallAndOddEvenLR() 
	: LRBase()
{
	m_fAccordLR = 3.5;
}
BigSmallAndOddEvenLR::~BigSmallAndOddEvenLR()
{

}
BigSmallAndOddEvenLR::BigSmallAndOddEvenLR(const BigSmallAndOddEvenLR& other)
{
	BigSmallAndOddEvenLR::operator = (other);
}
const BigSmallAndOddEvenLR& BigSmallAndOddEvenLR::operator = (const BigSmallAndOddEvenLR& other)
{
	if (&other != this)
	{
		m_fAccordLR = other.m_fAccordLR;

		m_g1314Coll = other.m_g1314Coll;
		m_lcColl = other.m_lcColl;
	}

	return (*this);
}

bool BigSmallAndOddEvenLR::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (BT_BigSmallAndOddEven == lj.eBetType)
	{
		if (BST_Big != lj.eBetSubType && BST_Small != lj.eBetSubType
			&& BST_Odd != lj.eBetSubType && BST_Even != lj.eBetSubType)
			return false;
	}

	return true;
}

bool BigSmallAndOddEvenLR::getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, bool bUse890, float& flr)
{
	if (BT_BigSmallAndOddEven == lj.eBetType)
	{
		if (lot.isBigSmallAndOddEven(lj.eBetSubType))
		{
			flr = m_fAccordLR;
		
			if (lot.isSum1314())
			{
				for (int k = m_g1314Coll.size() - 1; k >= 0; --k)
				{
					tGrossAnd1314LRDef& def = m_g1314Coll[k];

					if (def.bUseThis && nTotalMount > def.nGross)
					{
						flr = def.fTimes;
						break;
					}
				}
			}

			{
				if (lot.is3Same())
				{
					tLikeCardLRDef& def = m_lcColl[0];

					if (def.bUseThis)
						flr = def.fTimes;
				}
				else if (lot.is2Same())
				{
					tLikeCardLRDef& def = m_lcColl[1];

					if (def.bUseThis)
						flr = def.fTimes;
				}
				else if (lot.isContinous(bUse890))
				{
					tLikeCardLRDef& def = m_lcColl[2];

					if (def.bUseThis)
						flr = def.fTimes;
				}
			}
			
			return true;
		}
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

GroupByLR::GroupByLR() 
	: LRBase()
{
	m_bUseAlg1 = true;

	m_fAccordLR = 5.5;
	m_bUse1314LR = true;
	m_f1314LR = 2.5;

	m_fBigEvenAndSmallOddLR = 5.5;
	m_fSmallEvenAndBigOddLR = 5.5;
}
GroupByLR::~GroupByLR()
{

}
GroupByLR::GroupByLR(const GroupByLR& other)
{
	GroupByLR::operator = (other);
}
const GroupByLR& GroupByLR::operator = (const GroupByLR& other)
{
	if (&other != this)
	{
		m_bUseAlg1 = other.m_bUseAlg1;

		m_fAccordLR = other.m_fAccordLR;
		m_bUse1314LR = other.m_bUse1314LR;
		m_f1314LR = other.m_f1314LR;

		m_fBigEvenAndSmallOddLR = other.m_fBigEvenAndSmallOddLR;
		m_fSmallEvenAndBigOddLR = other.m_fSmallEvenAndBigOddLR;

		m_g1314Coll = other.m_g1314Coll;
		m_lcColl = other.m_lcColl;
	}

	return (*this);
}

bool GroupByLR::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (BT_GroupBy == lj.eBetType)
	{
		if (BST_BigOdd != lj.eBetSubType && BST_BigEven != lj.eBetSubType
			&& BST_SmallOdd != lj.eBetSubType && BST_SmallEven != lj.eBetSubType)
			return false;
	}

	return true;
}

bool GroupByLR::getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, bool bUse890, float& flr)
{
	if (BT_GroupBy == lj.eBetType)
	{
		if (lot.isGroupBy(lj.eBetSubType))
		{
			bool bIs1314 = lot.isSum1314();

			if (m_bUseAlg1)
			{
				flr = m_fAccordLR;

				if (bIs1314 && m_bUse1314LR)
					flr = m_f1314LR;
			}
			else
			{
				BetSubType bst = lj.eBetSubType;

				if (bst == BST_BigEven || bst == BST_SmallOdd)
					flr = m_fBigEvenAndSmallOddLR;

				if (bst == BST_SmallEven || bst == BST_BigOdd)
					flr = m_fSmallEvenAndBigOddLR;
			}

			{
				if (bIs1314)
				{
					for (int k = m_g1314Coll.size() - 1; k >= 0; --k)
					{
						tGrossAnd1314LRDef& def = m_g1314Coll[k];

						if (def.bUseThis && nTotalMount > def.nGross)
						{
							flr = def.fTimes;
							break;
						}
					}
				}

				{
					if (lot.is3Same())
					{
						tLikeCardLRDef& def = m_lcColl[0];

						if (def.bUseThis)
							flr = def.fTimes;
					}
					else if (lot.is2Same())
					{
						tLikeCardLRDef& def = m_lcColl[1];

						if (def.bUseThis)
							flr = def.fTimes;
					}
					else if (lot.isContinous(bUse890))
					{
						tLikeCardLRDef& def = m_lcColl[2];

						if (def.bUseThis)
							flr = def.fTimes;
					}
				}
			}
		}

		return true;
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

MinMaxByLR::MinMaxByLR() 
	: LRBase()
{
	m_fAccordLR = 15;
}
MinMaxByLR::~MinMaxByLR()
{

}
MinMaxByLR::MinMaxByLR(const MinMaxByLR& other)
{
	MinMaxByLR::operator = (other);
}
const MinMaxByLR& MinMaxByLR::operator = (const MinMaxByLR& other)
{
	if (&other != this)
	{
		m_fAccordLR = other.m_fAccordLR;
	}

	return (*this);
}

bool MinMaxByLR::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (BT_MinMaxBy == lj.eBetType)
	{
		if(BST_Min != lj.eBetSubType && BST_Max != lj.eBetSubType)
			return false;
	}

	return true;
}

bool MinMaxByLR::getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr)
{
	if (BT_MinMaxBy == lj.eBetType)
	{
		if (lot.isMinMaxBy(lj.eBetSubType))
		{
			flr = m_fAccordLR;

			return true;
		}
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

LikeCardLR::LikeCardLR() 
	: LRBase()
{
	m_bUse890 = false;
}
LikeCardLR::~LikeCardLR()
{

}
LikeCardLR::LikeCardLR(const LikeCardLR& other)
{
	LikeCardLR::operator = (other);
}
const LikeCardLR& LikeCardLR::operator = (const LikeCardLR& other)
{
	if (&other != this)
	{
		m_lcColl = other.m_lcColl;

		m_bUse890 = other.m_bUse890;
	}

	return (*this);
}

bool LikeCardLR::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (BT_CardBy == lj.eBetType)
	{
		int ind = lj.eBetSubType - BST_3Same_Card;
		if (ind >= 0 && ind < m_lcColl.size())
		{
			tLikeCardLRDef& def = m_lcColl[ind];
			if (!def.bUseThis)
				return false;
		}
		else
			Q_ASSERT(false);
	}

	return true;
}

bool LikeCardLR::getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr)
{
	if (BT_CardBy == lj.eBetType)
	{
		if (lot.isLikeCard(m_bUse890,lj.eBetSubType))
		{
			int ind = lj.eBetSubType - BST_3Same_Card;

			if (ind >= 0 && ind < m_lcColl.size())
			{
				tLikeCardLRDef& def = m_lcColl[ind];
				if (def.bUseThis)
				{
					flr = def.fTimes;
				}
			}
			else
				Q_ASSERT(false);

			return true;
		}
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

LRSettings::LRSettings()
{
	toDefault();
}
LRSettings::~LRSettings()
{

}
LRSettings::LRSettings(const LRSettings& other)
{
	LRSettings::operator = (other);
}
const LRSettings& LRSettings::operator = (const LRSettings& other)
{
	if (&other != this)
	{
		m_sdLR = other.m_sdLR;
		m_bsoeLR = other.m_bsoeLR;
		m_grpLR = other.m_grpLR;
		m_mmLR = other.m_mmLR;
		m_lcLR = other.m_lcLR;
	}

	return (*this);
}

bool LRSettings::checkRules(const tLotJudge& lj, QString& strMsg)
{
	if (!m_sdLR.checkRules(lj, strMsg))
		return false;

	if (!m_bsoeLR.checkRules(lj, strMsg))
		return false;

	if (!m_grpLR.checkRules(lj, strMsg))
		return false;

	if (!m_mmLR.checkRules(lj, strMsg))
		return false;

	if (!m_lcLR.checkRules(lj, strMsg))
		return false;

	return true;
}

bool LRSettings::getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, float& flr)
{
	flr = 0;

	bool bUse890 = m_lcLR.m_bUse890;

	if (m_sdLR.getLostrate(lot, lj, flr))
		return true;

	if (m_bsoeLR.getLostrate(lot, lj, nTotalMount, bUse890, flr))
		return true;

	if (m_grpLR.getLostrate(lot, lj, nTotalMount, bUse890, flr))
		return true;

	if (m_mmLR.getLostrate(lot, lj, flr))
		return true;

	if (m_lcLR.getLostrate(lot, lj, flr))
		return true;

	return true;
}

void LRSettings::toDefault()
{
	{
		m_sdLR.m_bUseAccordLR = true;

		m_sdLR.m_fAccordLR = 2;
	}

	{
		m_bsoeLR.m_fAccordLR = 3.5;

		{
			{
				tGrossAnd1314LRDef def;

				def.bUseThis = true;
				def.nGross = 1000;
				def.fTimes = 2.5;

				m_bsoeLR.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = true;
				def.nGross = 5000;
				def.fTimes = 2;

				m_bsoeLR.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = true;
				def.nGross = 10000;
				def.fTimes = 1;

				m_bsoeLR.m_g1314Coll.append(def);
			}
		}

		{
			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_3Same_Card;
				def.fTimes = 0;

				m_bsoeLR.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_2Same_Card;
				def.fTimes = 0;

				m_bsoeLR.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_Continuous_Card;
				def.fTimes = 0;

				m_bsoeLR.m_lcColl.append(def);
			}
		}
	}

	{
		m_grpLR.m_bUseAlg1 = true;

		m_grpLR.m_fAccordLR = 5.5;
		m_grpLR.m_bUse1314LR = true;
		m_grpLR.m_f1314LR = 2.5;

		m_grpLR.m_fBigEvenAndSmallOddLR = 5.5;
		m_grpLR.m_fSmallEvenAndBigOddLR = 5.5;

		{
			{
				tGrossAnd1314LRDef def;

				def.bUseThis = false;
				def.nGross = 5000;
				def.fTimes = 1.5;

				m_grpLR.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = false;
				def.nGross = 10000;
				def.fTimes = 1;

				m_grpLR.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = false;
				def.nGross = 50000;
				def.fTimes = 1;

				m_grpLR.m_g1314Coll.append(def);
			}
		}

		{
			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_3Same_Card;
				def.fTimes = 0;

				m_grpLR.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_2Same_Card;
				def.fTimes = 0;

				m_grpLR.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.bUseThis = false;
				def.nType = BST_Continuous_Card;
				def.fTimes = 0;

				m_grpLR.m_lcColl.append(def);
			}
		}
	}

	{
		m_mmLR.m_fAccordLR = 15;
	}

	{
		m_lcLR.m_bUse890 = false;

		{
			tLikeCardLRDef def;

			def.bUseThis = false;
			def.nType = BST_3Same_Card;
			def.fTimes = 30;

			m_lcLR.m_lcColl.append(def);
		}

		{
			tLikeCardLRDef def;

			def.bUseThis = false;
			def.nType = BST_2Same_Card;
			def.fTimes = 30;

			m_lcLR.m_lcColl.append(def);
		}

		{
			tLikeCardLRDef def;

			def.bUseThis = false;
			def.nType = BST_Continuous_Card;
			def.fTimes = 30;

			m_lcLR.m_lcColl.append(def);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////