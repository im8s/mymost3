#include "gdata.h"

#include <QDebug>


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

bool tLotJudge::addBetInfo(const QString& pid, const QString& strName, const QString& strInfo)
{
	QString strBetStr = strInfo.simplified();

	{
		if (strBetStr == ZN_STR("取消"))
		{
			this->pid = pid;
			this->strName = strName;

			return true;
		}
	}

	{
		static const QString strlstTitles[] = { ZN_STR("草"),ZN_STR("."),ZN_STR("艹"),ZN_STR("操") };

		QString strDig0;
		QString strDig1;
		int sel = -1;
		{
			for (int k = 0; k < sizeof(strlstTitles) / sizeof(strlstTitles[0]); ++k)
			{
				QString strTitle = strlstTitles[k];

				int pos = strBetStr.indexOf(strTitle);
				if (-1 != pos)
				{
					strDig0 = strBetStr.left(pos).simplified();
					strDig1 = strBetStr.mid(pos + strTitle.size()).simplified();
					sel = k;

					break;
				}
			}
		}

		if (-1 != sel && isDigitStr(strDig0) && isDigitStr(strDig1))
		{
			int nDig0 = strDig0.toInt();
			int nDig1 = strDig1.toInt();

			if (nDig0 >= MIN_SD_SUM && nDig0 <= MAX_SD_SUM)
			{
				eBetType = BT_SumDigital;
				eBetSubType = BST_SumDigital;
				strBet = strInfo;
				nSum = nDig0;
				nAmount = nDig1;
				this->pid = pid;
				this->strName = strName;

				//qDebug() << ZN_STR("PID = %1 ==> ").arg(pid) + asString();

				//strMsg = ZN_STR("投注类型: %1,子类型: %2, 金额: %3, 数字: %4").arg(lj.eBetType).arg(lj.eBetSubType).arg(lj.nAmount).arg(lj.nSum);

				return true;
			}
		}
	}

	{
		static const QString strlstTitles[] = { ZN_STR("极大"),ZN_STR("极小") };

		QString strDig0;
		QString strDig1;
		int sel = -1;
		{
			for (int k = 0; k < sizeof(strlstTitles) / sizeof(strlstTitles[0]); ++k)
			{
				QString strTitle = strlstTitles[k];

				int pos = strBetStr.indexOf(strTitle);
				if (-1 != pos)
				{
					strDig0 = strBetStr.left(pos).simplified();
					strDig1 = strBetStr.mid(pos + strTitle.size()).simplified();

					sel = k;

					break;
				}
			}
		}

		if (-1 != sel && (isDigitStr(strDig0) || isDigitStr(strDig1)))
		{
			int nDig0 = strDig0.toInt();
			if (isDigitStr(strDig1))
				nDig0 = strDig1.toInt();

			if (nDig0 > 0)
			{
				eBetType = BT_MinMaxBy;
				eBetSubType = (sel == 0 ? BST_Max : BST_Min);
				strBet = strInfo;
				nSum = -1;
				nAmount = nDig0;
				this->pid = pid;
				this->strName = strName;

				//qDebug() << ZN_STR("PID = %1 ==> ").arg(pid) + asString();

				//strMsg = ZN_STR("投注类型: %1,子类型: %2, 金额: %3").arg(lj.eBetType).arg(lj.eBetSubType).arg(lj.nAmount);

				return true;
			}
		}
	}

	{
		static const QString strlstTitles[] = { ZN_STR("豹子"),ZN_STR("对子"),ZN_STR("顺子") };

		QString strDig0;
		QString strDig1;
		int sel = -1;
		{
			for (int k = 0; k < sizeof(strlstTitles) / sizeof(strlstTitles[0]); ++k)
			{
				QString strTitle = strlstTitles[k];

				int pos = strBetStr.indexOf(strTitle);
				if (-1 != pos)
				{
					strDig0 = strBetStr.left(pos).simplified();
					strDig1 = strBetStr.mid(pos + strTitle.size()).simplified();

					sel = k;

					break;
				}
			}
		}

		if (-1 != sel && (isDigitStr(strDig0) || isDigitStr(strDig1)))
		{
			int nDig0 = strDig0.toInt();
			if (isDigitStr(strDig1))
				nDig0 = strDig1.toInt();

			if (nDig0 > 0)
			{
				eBetType = BT_CardBy;
				eBetSubType = (0 == sel ? BST_3Same_Card : (1 == sel ? BST_2Same_Card : BST_Continuous_Card));
				strBet = strInfo;
				nSum = -1;
				nAmount = nDig0;
				this->pid = pid;
				this->strName = strName;

				//qDebug() << ZN_STR("PID = %1 ==> ").arg(pid) + asString();

				//strMsg = ZN_STR("投注类型: %1,子类型: %2, 金额: %3").arg(lj.eBetType).arg(lj.eBetSubType).arg(lj.nAmount);

				return true;
			}
		}
	}

	{
		static const QString strlstTitles[] = { ZN_STR("大单"),ZN_STR("大双"),ZN_STR("小单"),ZN_STR("小双") };

		QString strDig0;
		QString strDig1;
		int sel = -1;
		{
			for (int k = 0; k < sizeof(strlstTitles) / sizeof(strlstTitles[0]); ++k)
			{
				QString strTitle = strlstTitles[k];

				int pos = strBetStr.indexOf(strTitle);
				if (-1 != pos)
				{
					strDig0 = strBetStr.left(pos).simplified();
					strDig1 = strBetStr.mid(pos + strTitle.size()).simplified();

					sel = k;

					break;
				}
			}
		}

		if (-1 != sel && (isDigitStr(strDig0) || isDigitStr(strDig1)))
		{
			int nDig0 = strDig0.toInt();
			if (isDigitStr(strDig1))
				nDig0 = strDig1.toInt();

			if (nDig0 > 0)
			{
				eBetType = BT_GroupBy;
				eBetSubType = (0 == sel ? BST_BigOdd : (1 == sel ? BST_BigEven :
								(2 == sel ? BST_SmallOdd : BST_SmallEven)));
				strBet = strInfo;
				nSum = -1;
				nAmount = nDig0;
				this->pid = pid;
				this->strName = strName;

				//qDebug() << ZN_STR("PID = %1 ==> ").arg(pid) + asString();

				//strMsg = ZN_STR("投注类型: %1,子类型: %2, 金额: %3").arg(lj.eBetType).arg(lj.eBetSubType).arg(lj.nAmount);

				return true;
			}
		}
	}

	{
		static const QString strlstTitles[] = { ZN_STR("大"),ZN_STR("小"),ZN_STR("单"),ZN_STR("双") };

		QString strDig0;
		QString strDig1;
		int sel = -1;
		{
			for (int k = 0; k < sizeof(strlstTitles) / sizeof(strlstTitles[0]); ++k)
			{
				QString strTitle = strlstTitles[k];

				int pos = strBetStr.indexOf(strTitle);
				if (-1 != pos)
				{
					strDig0 = strBetStr.left(pos).simplified();
					strDig1 = strBetStr.mid(pos + strTitle.size()).simplified();

					sel = k;

					break;
				}
			}
		}

		if (-1 != sel && (isDigitStr(strDig0) || isDigitStr(strDig1)))
		{
			int nDig0 = strDig0.toInt();
			if (isDigitStr(strDig1))
				nDig0 = strDig1.toInt();

			if (nDig0 > 0)
			{
				eBetType = BT_BigSmallAndOddEven;
				eBetSubType = (0 == sel ? BST_Big : (1 == sel ? BST_Small :
								(2 == sel ? BST_Odd : BST_Even)));
				strBet = strInfo;
				nSum = -1;
				nAmount = nDig0;
				this->pid = pid;
				this->strName = strName;

				//qDebug() << ZN_STR("PID = %1 ==> ").arg(pid) + asString();

				//strMsg = ZN_STR("投注类型: %1,子类型: %2, 金额: %3").arg(lj.eBetType).arg(lj.eBetSubType).arg(lj.nAmount);

				return true;
			}
		}
	}

	return false;
}

bool tLotJudge::isReverseCombined(const tLotJudge& lj, QString& strMsg)
{
	if (BT_GroupBy == lj.eBetType && BT_GroupBy == eBetType && lj.eBetSubType != eBetSubType)
	{
		if (lj.eBetSubType + eBetSubType == 15)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}
bool tLotJudge::isReverseCombined(const tLotJudge& lj, QString& strMsg) const
{
	if (BT_GroupBy == lj.eBetType && BT_GroupBy == eBetType && lj.eBetSubType != eBetSubType)
	{
		if (lj.eBetSubType + eBetSubType == 15)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}

bool tLotJudge::isSyntropyCombined(const tLotJudge& lj, QString& strMsg)
{
	if (BT_GroupBy == lj.eBetType && BT_GroupBy == eBetType && lj.eBetSubType != eBetSubType)
	{
		if (lj.eBetSubType + eBetSubType == 13 || lj.eBetSubType + eBetSubType == 14
			|| lj.eBetSubType + eBetSubType == 16 || lj.eBetSubType + eBetSubType == 17)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}
bool tLotJudge::isSyntropyCombined(const tLotJudge& lj, QString& strMsg) const
{
	if (BT_GroupBy == lj.eBetType && BT_GroupBy == eBetType && lj.eBetSubType != eBetSubType)
	{
		if (lj.eBetSubType + eBetSubType == 13 || lj.eBetSubType + eBetSubType == 14
			|| lj.eBetSubType + eBetSubType == 16 || lj.eBetSubType + eBetSubType == 17)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}

bool tLotJudge::isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg)
{
	if (BT_BigSmallAndOddEven == lj.eBetType && BT_BigSmallAndOddEven == eBetType && lj.eBetSubType != eBetSubType)
	{
		if (lj.eBetSubType + eBetSubType == 5 || lj.eBetSubType + eBetSubType == 9)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}
bool tLotJudge::isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg) const
{
	if (BT_BigSmallAndOddEven == lj.eBetType && BT_BigSmallAndOddEven == eBetType)
	{
		if (lj.eBetSubType + eBetSubType == 5 || lj.eBetSubType + eBetSubType == 9)
		{
			strMsg = getBetSubTypeString(eBetSubType) + ",";
			strMsg += getBetSubTypeString(lj.eBetSubType);

			return true;
		}
	}

	return false;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

bool tBetInfo::getSDNumAndSDMountAndTotalMount(int& nSDNum, int& nSDMount, int& nTotalMount)
{
	nSDNum = 0;
	nSDMount = 0;
	nTotalMount = 0;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj = ljColl[k];

		if (BT_SumDigital == lj.eBetType)
		{
			++nSDNum;
			nSDMount += lj.nAmount;
		}

		nTotalMount += lj.nAmount;
	}

	return true;
}

bool tBetInfo::getSDNumAndSDMountAndTotalMount(int& nSDNum, int& nSDMount, int& nTotalMount) const
{
	nSDNum = 0;
	nSDMount = 0;
	nTotalMount = 0;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj = ljColl[k];

		if (BT_SumDigital == lj.eBetType)
		{
			++nSDNum;
			nSDMount += lj.nAmount;
		}

		nTotalMount += lj.nAmount;
	}

	return true;
}

int tBetInfo::getTotalMount()
{
	int nTotalMount = 0;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj = ljColl[k];

		nTotalMount += lj.nAmount;
	}

	return nTotalMount;
}

int tBetInfo::getTotalMount() const
{
	int nTotalMount = 0;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj = ljColl[k];

		nTotalMount += lj.nAmount;
	}

	return nTotalMount;
}

bool tBetInfo::isKillCombined(const tLotJudge& lj, QString& strMsg)
{
	IntSet coll;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj2 = ljColl[k];

		if (BT_GroupBy == lj2.eBetType)
		{
			coll << lj2.eBetSubType;
		}
	}

	if (BT_GroupBy == lj.eBetType)
	{
		coll << lj.eBetSubType;
	}

	bool b = (coll.size() >= 3);
	if (b)
	{
		strMsg = getBetSubTypeStrings(coll);
	}

	return b;
}

bool tBetInfo::isKillCombined(const tLotJudge& lj, QString& strMsg) const
{
	IntSet coll;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj2 = ljColl[k];

		if (BT_GroupBy == lj2.eBetType)
		{
			coll << lj2.eBetSubType;
		}
	}

	if (BT_GroupBy == lj.eBetType)
	{
		coll << lj.eBetSubType;
	}

	bool b = (coll.size() >= 3);
	if (b)
	{
		strMsg = getBetSubTypeStrings(coll);
	}

	return b;
}

bool tBetInfo::isReverseCombined(const tLotJudge& lj, QString& strMsg)
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		tLotJudge& lj2 = ljColl[k];

		if (lj2.isReverseCombined(lj,strMsg))
		{
			return true;
		}
	}

	return false;
}
bool tBetInfo::isReverseCombined(const tLotJudge& lj, QString& strMsg) const
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj2 = ljColl[k];

		if (lj2.isReverseCombined(lj, strMsg))
		{
			return true;
		}
	}

	return false;
}

bool tBetInfo::isSyntropyCombined(const tLotJudge& lj, QString& strMsg)
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		tLotJudge& lj2 = ljColl[k];

		if (lj2.isSyntropyCombined(lj, strMsg))
		{
			return true;
		}
	}

	return false;
}
bool tBetInfo::isSyntropyCombined(const tLotJudge& lj, QString& strMsg) const
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj2 = ljColl[k];

		if (lj2.isSyntropyCombined(lj, strMsg))
		{
			return true;
		}
	}

	return false;
}

bool tBetInfo::isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg)
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		tLotJudge& lj2 = ljColl[k];

		if (lj2.isReverseBigSmallAndOddEven(lj, strMsg))
		{
			return true;
		}
	}

	return false;
}

bool tBetInfo::isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg) const
{
	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj2 = ljColl[k];

		if (lj2.isReverseBigSmallAndOddEven(lj, strMsg))
		{
			return true;
		}
	}

	return false;
}

QString tBetInfo::getBetBill()
{
	QString strBill;

	for (int k = 0; k < ljColl.size(); ++k)
	{
		const tLotJudge& lj = ljColl[k];

		strBill += "\t" + lj.asResult() + "\n";
	}

	if (strBill.isEmpty())
		strBill = ZN_STR("\t无\n");

	strBill = ZN_STR("%1 [共%2注]: \n").arg(strName).arg(ljColl.size()) + strBill + "\n";

	return strBill;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

