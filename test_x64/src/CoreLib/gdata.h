#pragma once

#include "corelib_global.h"

#include "ToolFunc.h"

#include <qglobal.h>
#include <QString>
#include <QMap>
#include <QVector>
#include <QList>
#include <QSet>
#include <QDateTime>
#include <QMetaType>


typedef QVector< int >			IntVector;
typedef QSet< int >				IntSet;
typedef QMap< int, float >		Int2FltMap;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tServerTime
{
	QString		strServerTime;

	QDateTime	dtServerTime;

	tServerTime()
	{

	}
	~tServerTime()
	{

	}
	tServerTime(const tServerTime& other)
	{
		tServerTime::operator = (other);
	}
	const tServerTime& operator = (const tServerTime& other)
	{
		if (&other != this)
		{
			strServerTime = other.strServerTime;
			dtServerTime = other.dtServerTime;
		}

		return (*this);
	}

	bool doProcess()
	{
		//qint64 nServerTime = strServerTime.toLongLong() / 1000;
		
		//dtServerTime = QDateTime::fromTime_t(nServerTime);

		dtServerTime = QDateTime::fromString(strServerTime, "yyyyMMddhhmmss");

		//strServerTime = dtServerTime.toString("yyyy-MM-dd hh:mm:ss");

		return true;
	}
};

Q_DECLARE_METATYPE(tServerTime);

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

enum BetType
{
	BT_None					=	0,
	BT_SumDigital			=	1,
	BT_BigSmallAndOddEven	=	2,
	BT_GroupBy				=	3,
	BT_MinMaxBy				=	4,
	BT_CardBy				=	5,

	BT_Count,
};

enum BetSubType
{
	BST_None				=	0,

	BST_SumDigital			=	1,

	BST_Big					=	2,
	BST_Small				=	3,
	BST_Odd					=	4,
	BST_Even				=	5,

	BST_BigOdd				=	6,
	BST_BigEven				=	7,
	BST_SmallOdd			=	8,
	BST_SmallEven			=	9,

	BST_Min					=	10,
	BST_Max					=	11,

	BST_3Same_Card			=	12,
	BST_2Same_Card			=	13,
	BST_Continuous_Card		=	14,

	BST_Count,
};

static const QString btStrings[] = {
	ZN_STR("无"),
	ZN_STR("单点数字和"),
	ZN_STR("大小单双"),
	ZN_STR("组合"),
	ZN_STR("极大极小"),
	ZN_STR("类牌"),
};

static const QString bstStrings[] = {
	ZN_STR("无"),
	ZN_STR("和值"),
	ZN_STR("大"),ZN_STR("小"),ZN_STR("单"),ZN_STR("双"),
	ZN_STR("大单"),ZN_STR("大双"),ZN_STR("小单"),ZN_STR("小双"),
	ZN_STR("极小"),ZN_STR("极大"),
	ZN_STR("豹子"),ZN_STR("对子"),ZN_STR("顺子"),
};

static QString getBetTypeString(int type)
{
	if (type >= 0 && type < BT_Count)
		return btStrings[type];

	return "";
}
static QString getBetSubTypeString(int type)
{
	if (type >= 0 && type < BST_Count)
		return bstStrings[type];

	return "";
}

static QString getBetTypeStrings(const IntSet& coll)
{
	QString str;

	for (IntSet::const_iterator cit = coll.begin();
		cit != coll.end(); ++cit)
	{
		int type = (*cit);

		if (!str.isEmpty())
			str += ",";
		str += getBetTypeString(type);
	}

	return str;
}
static QString getBetSubTypeStrings(const IntSet& coll)
{
	QString str;

	for (IntSet::const_iterator cit = coll.begin();
		cit != coll.end(); ++cit)
	{
		int type = (*cit);

		if (!str.isEmpty())
			str += ",";
		str += getBetSubTypeString(type);
	}

	return str;
}

#define MIN_SD_SUM		0	
#define MAX_SD_SUM		27

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tLottery
{
	QString		strPeriods;
	QString 	strBeginTime;
	QString 	strOpenTime;
	QString 	strCollectTime;
	QString 	strOpenContent;

	qint32		nPeriods;
	QDateTime	dtBeginTime;
	QDateTime	dtOpenTime;
	QDateTime	dtCollectTime;
	char		anums[3];

	tLottery()
	{
		nPeriods = -1;
		memset(anums, 0, sizeof(anums));
	}
	~tLottery()
	{

	}
	tLottery(const tLottery& other)
	{
		tLottery::operator = (other);
	}
	const tLottery& operator = (const tLottery& other)
	{
		if (&other != this)
		{
			strPeriods = other.strPeriods;
			strBeginTime = other.strBeginTime;
			strOpenTime = other.strOpenTime;
			strCollectTime = other.strCollectTime;
			strOpenContent = other.strOpenContent;

			nPeriods = other.nPeriods;
			dtBeginTime = other.dtBeginTime;
			dtOpenTime = other.dtOpenTime;
			dtCollectTime = other.dtCollectTime;
			memcpy(anums, other.anums, sizeof(anums));
		}

		return (*this);
	}
	
	bool doProcess(bool bIsLi)
	{
		if (bIsLi)
		{
			nPeriods = strPeriods.toInt();

			//QDateTime time = QDateTime::currentDateTime();   //获取当前时间  
			//int timeT = time.toTime_t();

			qint64 nBeginTime = strBeginTime.toLongLong() / 1000;
			qint64 nOpenTime = strOpenTime.toLongLong() / 1000;
			qint64 nCollectTime = strCollectTime.toLongLong() / 1000;

			dtBeginTime = QDateTime::fromTime_t(nBeginTime);
			dtOpenTime = QDateTime::fromTime_t(nOpenTime);
			dtCollectTime = QDateTime::fromTime_t(nCollectTime);

#if 0
			strBeginTime = dtBeginTime.toString("MM-dd hh:mm");
			strOpenTime = dtOpenTime.toString("MM-dd hh:mm");
			strCollectTime = dtCollectTime.toString("MM-dd hh:mm");
#else
			strBeginTime = dtBeginTime.toString("yyyy-MM-dd hh:mm:ss");
			strOpenTime = dtOpenTime.toString("yyyy-MM-dd hh:mm:ss");
			strCollectTime = dtCollectTime.toString("yyyy-MM-dd hh:mm:ss");
#endif

			QStringList strlst = strOpenContent.split('+');
			if (strlst.size() == 3)
			{
				anums[0] = strlst[0].toShort();
				anums[1] = strlst[1].toShort();
				anums[2] = strlst[2].toShort();

				return true;
			}
		}
		else
		{
			nPeriods = strPeriods.toInt();

			dtBeginTime = QDateTime::fromString(strBeginTime, "yyyy-MM-dd hh:mm:ss");
			dtOpenTime = QDateTime::fromString(strOpenTime, "yyyy-MM-dd hh:mm:ss");

#if 0
			strBeginTime = dtBeginTime.toString("MM-dd hh:mm");
			strOpenTime = dtOpenTime.toString("MM-dd hh:mm");
#else
			
#endif

			return true;
		}

		return false;
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	bool addBetInfo(int dig0, int dig1, int dig2)
	{
		if (dig0 >= 0 && dig0 <= 9
			&& dig1 >= 0 && dig1 <= 9
			&& dig2 >= 0 && dig2 <= 9)
		{
			anums[0] = dig0;
			anums[1] = dig1;
			anums[2] = dig2;

			return true;
		}

		return false;
	}

	bool addBetInfo(const QString& strDig0, const QString& strDig1, const QString& strDig2)
	{
		int dig0 = strDig0.toShort();
		int dig1 = strDig1.toShort();
		int dig2 = strDig2.toShort();

		return addBetInfo(dig0, dig1, dig2);
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	bool isMin(int sum)
	{
		if (sum >= 0 && sum <= 5)
			return true;
		return false;
	}
	bool isMin(int sum) const
	{
		if (sum >= 0 && sum <= 5)
			return true;
		return false;
	}

	bool isMax(int sum)
	{
		if (sum >= 22 && sum <= 27)
			return true;
		return false;
	}
	bool isMax(int sum) const
	{
		if (sum >= 22 && sum <= 27)
			return true;
		return false;
	}

	bool isOdd(int sum)
	{
		if ((sum % 2) != 0)
			return true;
		return false;
	}
	bool isOdd(int sum) const
	{
		if ((sum % 2) != 0)
			return true;
		return false;
	}

	bool isEven(int sum)
	{
		if ((sum % 2) == 0)
			return true;
		return false;
	}
	bool isEven(int sum) const
	{
		if ((sum % 2) == 0)
			return true;
		return false;
	}

	bool isBig(int sum)
	{
		if (sum >= 14 && sum <= 27)
			return true;
		return false;
	}
	bool isBig(int sum) const
	{
		if (sum >= 14 && sum <= 27)
			return true;
		return false;
	}

	bool isSmall(int sum)
	{
		if (sum >= 0 && sum <= 13)
			return true;
		return false;
	}
	bool isSmall(int sum) const
	{
		if (sum >= 0 && sum <= 13)
			return true;
		return false;
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	bool is3Same(const char anums[3])
	{
		if (anums[0] == anums[1] && anums[0] == anums[2])
			return true;
		return false;
	}
	bool is3Same(const char anums[3]) const
	{
		if (anums[0] == anums[1] && anums[0] == anums[2])
			return true;
		return false;
	}

	bool is2Same(const char anums[3])
	{
		if ((anums[0] == anums[1] && anums[0] != anums[2])
			|| (anums[0] == anums[2] && anums[0] != anums[1])
			|| (anums[1] == anums[2] && anums[0] != anums[1]))
			return true;
		return false;
	}
	bool is2Same(const char anums[3]) const
	{
		if ((anums[0] == anums[1] && anums[0] != anums[2])
			|| (anums[0] == anums[2] && anums[0] != anums[1])
			|| (anums[1] == anums[2] && anums[0] != anums[1]))
			return true;
		return false;
	}

	bool isContinous(const char anums[3], bool bUse890)
	{
		QVector<int> coll;
		coll << anums[0] << anums[1] << anums[2];
		qSort(coll.begin(), coll.end(), qLess<int>());

		if (coll[0] + 1 == coll[1] && coll[1] + 1 == coll[2])
			return true;

		if (bUse890 && coll[0] == 0 && coll[1] == 8 && coll[2] == 9)
			return true;

		return false;
	}
	bool isContinous(const char anums[3], bool bUse890) const
	{
		QVector<int> coll;
		coll << anums[0] << anums[1] << anums[2];
		qSort(coll.begin(), coll.end(), qLess<int>());

		if (coll[0] + 1 == coll[1] && coll[1] + 1 == coll[2])
			return true;

		if (bUse890 && coll[0] == 0 && coll[1] == 8 && coll[2] == 9)
			return true;

		return false;
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	bool isSum(int nSum)
	{
		int sum = anums[0] + anums[1] + anums[2];
		return (sum == nSum);
	}
	bool isSum(int nSum) const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return (sum == nSum);
	}

	bool isSum1314()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return (sum == 13 || sum == 14);
	}
	bool isSum1314() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return (sum == 13 || sum == 14);
	}

	/////////////////////////////////////////////////////////////////////////////

	bool isBig()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBig(sum);
	}
	bool isBig() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBig(sum);
	}

	bool isSmall()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmall(sum);
	}
	bool isSmall() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmall(sum);
	}

	bool isOdd()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isOdd(sum);
	}
	bool isOdd() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isOdd(sum);
	}

	bool isEven()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isEven(sum);
	}
	bool isEven() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isEven(sum);
	}

	/////////////////////////////////////////////////////////////////////////////

	bool isBigOdd(int sum)
	{
		return isBig(sum) && isOdd(sum);
	}
	bool isBigOdd(int sum) const
	{
		return isBig(sum) && isOdd(sum);
	}

	bool isBigEven(int sum)
	{
		return isBig(sum) && isEven(sum);
	}
	bool isBigEven(int sum) const
	{
		return isBig(sum) && isEven(sum);
	}

	bool isSmallOdd(int sum)
	{
		return isSmall(sum) && isOdd(sum);
	}
	bool isSmallOdd(int sum) const
	{
		return isSmall(sum) && isOdd(sum);
	}

	bool isSmallEven(int sum)
	{
		return isSmall(sum) && isEven(sum);
	}
	bool isSmallEven(int sum) const
	{
		return isSmall(sum) && isEven(sum);
	}

	bool isBigOdd()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBigOdd(sum);
	}
	bool isBigOdd() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBigOdd(sum);
	}

	bool isBigEven()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBigEven(sum);
	}
	bool isBigEven() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isBigEven(sum);
	}

	bool isSmallOdd()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmallOdd(sum);
	}
	bool isSmallOdd() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmallOdd(sum);
	}

	bool isSmallEven()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmallEven(sum);
	}
	bool isSmallEven() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isSmallEven(sum);
	}

	/////////////////////////////////////////////////////////////////////////////

	bool isMin()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isMin(sum);
	}
	bool isMin() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isMin(sum);
	}

	bool isMax()
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isMax(sum);
	}
	bool isMax() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		return isMax(sum);
	}

	/////////////////////////////////////////////////////////////////////////////

	bool is3Same()
	{
		return is3Same(anums);
	}
	bool is3Same() const
	{
		return is3Same(anums);
	}

	bool is2Same()
	{
		return is2Same(anums);
	}
	bool is2Same() const
	{
		return is2Same(anums);
	}

	bool isContinous(bool bUse890)
	{
		return isContinous(anums, bUse890);
	}
	bool isContinous(bool bUse890) const
	{
		return isContinous(anums, bUse890);
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	bool isBigSmallAndOddEven(BetSubType bst)
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isBig(sum) && BST_Big == bst)
			return true;
		else if (isSmall(sum) && BST_Small == bst)
			return true;
		else if (isOdd(sum) && BST_Odd == bst)
			return true;
		else if (isEven(sum) && BST_Even == bst)
			return true;

		return false;
	}
	bool isBigSmallAndOddEven(BetSubType bst) const
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isBig(sum) && BST_Big == bst)
			return true;
		else if (isSmall(sum) && BST_Small == bst)
			return true;
		else if (isOdd(sum) && BST_Odd == bst)
			return true;
		else if (isEven(sum) && BST_Even == bst)
			return true;

		return false;
	}

	bool isGroupBy(BetSubType bst)
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isBigOdd(sum) && bst == BST_BigOdd)
			return true;
		else if (isSmallOdd(sum) && bst == BST_SmallOdd)
			return true;
		else if (isBigEven(sum) && bst == BST_BigEven)
			return true;
		else if (isSmallEven(sum) && bst == BST_SmallEven)
			return true;

		return false;
	}
	bool isGroupBy(BetSubType bst) const
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isBigOdd(sum) && bst == BST_BigOdd)
			return true;
		else if (isSmallOdd(sum) && bst == BST_SmallOdd)
			return true;
		else if (isBigEven(sum) && bst == BST_BigEven)
			return true;
		else if (isSmallEven(sum) && bst == BST_SmallEven)
			return true;

		return false;
	}

	bool isMinMaxBy(BetSubType bst)
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isMin(sum) && BST_Min == bst)
			return true;
		else if (isMax(sum) && BST_Max == bst)
			return true;

		return false;
	}
	bool isMinMaxBy(BetSubType bst) const
	{
		int sum = anums[0] + anums[1] + anums[2];

		if (isMin(sum) && BST_Min == bst)
			return true;
		else if (isMax(sum) && BST_Max == bst)
			return true;

		return false;
	}

	bool isLikeCard(bool bUse890, BetSubType bst)
	{
		if (is3Same() && BST_3Same_Card == bst)
			return true;
		else if (is2Same() && BST_2Same_Card == bst)
			return true;
		else if (isContinous(bUse890) && BST_Continuous_Card == bst)
			return true;

		return false;
	}
	bool isLikeCard(bool bUse890, BetSubType bst) const
	{
		if (is3Same() && BST_3Same_Card == bst)
			return true;
		else if (is2Same() && BST_2Same_Card == bst)
			return true;
		else if (isContinous(bUse890) && BST_Continuous_Card == bst)
			return true;

		return false;
	}

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	QString asSum() const
	{
		int sum = anums[0] + anums[1] + anums[2];
		
		QString str = QString::number(sum);

		return str;
	}

	QString asResult() const
	{
		QString str;

		int sum = anums[0] + anums[1] + anums[2];
		if (isSmall(sum))
			str = ZN_STR("小");
		else
			str = ZN_STR("大");

		str += (isEven(sum) ? ZN_STR("双") : ZN_STR("单"));
		
		return str;
	}

	QString asResultFor() const
	{
		QString str;

		int sum = anums[0] + anums[1] + anums[2];
		if (isSmall(sum))
			str = ZN_STR("小");
		else
			str = ZN_STR("大");

		str += (isEven(sum) ? ZN_STR("双") : ZN_STR("单"));

		if (isMax(sum))
			str += ZN_STR("极大");
		else if (isMin(sum))
			str += ZN_STR("极小");

		if (is3Same())
			str += ZN_STR("豹子");
		else if (is2Same())
			str += ZN_STR("对子");
		else if (isContinous(false))
			str += ZN_STR("顺子");

		str = ZN_STR("=") + QString::number(sum) + str;

		return str;
	}

	QString asAllResult() const
	{
		QString str = strOpenContent + "=" + asSum() + "(" + asResult() + ")";

		return str;
	}
};

Q_DECLARE_METATYPE(tLottery);

typedef QMap< qint32, tLottery* >	tLotteryMap;
typedef QMap< qint32, tLottery >	tLotteryRefMap;
typedef QList< qint32 >				tLotKeyList;

typedef QVector< tLottery >			tLotteryVector;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tLotJudge
{
	QString		pid;
	QString		strName;

	QString		strBet;

	BetType		eBetType;
	BetSubType	eBetSubType;
	int			nSum;
	int			nAmount;
	

	tLotJudge()
	{
		eBetType = BT_None;
		eBetSubType = BST_None;
		nSum = -1;
		nAmount = 0;
	}
	~tLotJudge()
	{

	}
	tLotJudge(const tLotJudge& other)
	{
		tLotJudge::operator = (other);
	}
	const tLotJudge& operator = (const tLotJudge& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strName = other.strName;

			strBet = other.strBet;
			eBetType = other.eBetType;
			eBetSubType = other.eBetSubType;
			nSum = other.nSum;
			nAmount = other.nAmount;
		}

		return (*this);
	}

	bool addBetInfo(const QString& pid, const QString& strName, const QString& strInfo);

	bool isReverseCombined(const tLotJudge& lj, QString& strMsg);
	bool isReverseCombined(const tLotJudge& lj, QString& strMsg) const;

	bool isSyntropyCombined(const tLotJudge& lj, QString& strMsg);
	bool isSyntropyCombined(const tLotJudge& lj, QString& strMsg) const;

	bool isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg);
	bool isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg) const;

	QString asString()
	{
#if 0
		QString str = ZN_STR("投注类型：") + btStrings[eBetType];
		str += ZN_STR(",子类型：") + bstStrings[eBetSubType];
		str += ZN_STR(",金额：%1").arg(nAmount);
#else
		QString str;
		
		if(BT_SumDigital == eBetType)
			str = "(" + btStrings[eBetType] + ")" + bstStrings[eBetSubType] + "[" + QString::number(nSum) + "]:" + QString::number(nAmount);
		else
			str = "(" + btStrings[eBetType] + ")" + bstStrings[eBetSubType] + ":" + QString::number(nAmount);
#endif

		return str;
	}

	QString asString() const
	{
#if 0
		QString str = ZN_STR("投注类型：") + btStrings[eBetType];
		str += ZN_STR(",子类型：") + bstStrings[eBetSubType];
		str += ZN_STR(",金额：%1").arg(nAmount);
#else
		QString str;

		if (BT_SumDigital == eBetType)
			str = "(" + btStrings[eBetType] + ")" + bstStrings[eBetSubType] + "[" + QString::number(nSum) + "]:" + QString::number(nAmount);
		else
			str = "(" + btStrings[eBetType] + ")" + bstStrings[eBetSubType] + ":" + QString::number(nAmount);
#endif

		return str;
	}

	QString asResult()
	{
		QString str;

		if (BT_SumDigital == eBetType)
			str = bstStrings[eBetSubType] + "[" + QString::number(nSum) + "]:" + QString::number(nAmount);
		else
			str = bstStrings[eBetSubType] + ":" + QString::number(nAmount);

		return str;
	}

	const QString asResult() const
	{
		QString str;

		if (BT_SumDigital == eBetType)
			str = bstStrings[eBetSubType] + "[" + QString::number(nSum) + "]:" + QString::number(nAmount);
		else
			str = bstStrings[eBetSubType] + ":" + QString::number(nAmount);

		return str;
	}
};

typedef QVector< tLotJudge >	tLotJudgeVector;

struct CORELIB_EXPORT tBetInfo
{
	QString				pid;
	QString				strName;

	tLotJudgeVector		ljColl;


	tBetInfo(const QString& id, const QString& name)
	{
		pid = id;
		strName = name;
	}
	tBetInfo()
	{
	}
	~tBetInfo()
	{

	}
	tBetInfo(const tBetInfo& other)
	{
		tBetInfo::operator = (other);
	}
	const tBetInfo& operator = (const tBetInfo& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strName = other.strName;

			ljColl = other.ljColl;
		}

		return (*this);
	}

	void append(const tLotJudge& lj)
	{
		pid = lj.pid;
		
		ljColl.append(lj);
	}

	void clear()
	{
		ljColl.clear();
	}

	bool getSDNumAndSDMountAndTotalMount(int& nSDNum, int& nSDMount, int& nTotalMount);
	bool getSDNumAndSDMountAndTotalMount(int& nSDNum, int& nSDMount, int& nTotalMount) const;

	int getTotalMount();
	int getTotalMount() const;

	bool isKillCombined(const tLotJudge& lj, QString& strMsg);
	bool isKillCombined(const tLotJudge& lj, QString& strMsg) const;

	bool isReverseCombined(const tLotJudge& lj, QString& strMsg);
	bool isReverseCombined(const tLotJudge& lj, QString& strMsg) const;

	bool isSyntropyCombined(const tLotJudge& lj, QString& strMsg);
	bool isSyntropyCombined(const tLotJudge& lj, QString& strMsg) const;

	bool isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg);
	bool isReverseBigSmallAndOddEven(const tLotJudge& lj, QString& strMsg) const;

	QString getBetBill();
};

typedef QMap < QString, tBetInfo >	tBetInfoMap;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tPScoreInfo
{
	QString		pid;
	QString		strName;

	float		fTotalScore;

	QString		strBetStr;

	float		fAccScore;
	float		fAccWScore;
	float		fAccLScore;
	float		fAccPayment;

	float		fThisScore;
	float		fThisWScore;
	float		fThisLScore;
	float		fThisPayment;

	int			nAccTurnNum;
	int			nAccLotNum;
	int			nAccWLotNum;
	int			nAccLLotNum;
	
	int			nThisLotNum;
	int			nThisWLotNum;
	int			nThisLLotNum;
	
	int			nType;


	tPScoreInfo()
	{
		fTotalScore = 0;

		fAccScore = 0;
		fAccWScore = 0;
		fAccLScore = 0;
		fAccPayment = 0;

		fThisScore = 0;
		fThisWScore = 0;
		fThisLScore = 0;
		fThisPayment = 0;

		nAccTurnNum = 0;
		nAccLotNum = 0;
		nAccWLotNum = 0;
		nAccLLotNum = 0;
		
		nThisLotNum = 0;
		nThisWLotNum = 0;
		nThisLLotNum = 0;

		nType = -1;
	}
	~tPScoreInfo()
	{

	}
	tPScoreInfo(const tPScoreInfo& other)
	{
		tPScoreInfo::operator = (other);
	}
	const tPScoreInfo& operator = (const tPScoreInfo& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strName = other.strName;

			fTotalScore = other.fTotalScore;

			strBetStr = other.strBetStr;

			fAccScore = other.fAccScore;
			fAccWScore = other.fAccWScore;
			fAccLScore = other.fAccLScore;
			fAccPayment = other.fAccPayment;


			fThisScore = other.fThisScore;
			fThisWScore = other.fThisWScore;
			fThisLScore = other.fThisLScore;
			fThisPayment = other.fThisPayment;

			nAccTurnNum = other.nAccTurnNum;
			nAccLotNum = other.nAccLotNum;
			nAccWLotNum = other.nAccWLotNum;
			nAccLLotNum = other.nAccLLotNum;
			
			nThisLotNum = other.nThisLotNum;
			nThisWLotNum = other.nThisWLotNum;
			nThisLLotNum = other.nThisLLotNum;

			nType = other.nType;
		}

		return (*this);
	}

	void resetNeeded()
	{
		fThisScore = 0;
		fThisWScore = 0;
		fThisLScore = 0;
		fThisPayment = 0;

		nThisLotNum = 0;
		nThisWLotNum = 0;
		nThisLLotNum = 0;

		strBetStr.clear();
	}
};

typedef QMap< QString, tPScoreInfo* >	tPScoreInfoMap;
typedef QMap< QString, tPScoreInfo >	tPScoreInfoRefMap;
typedef QList< QString >				tPIKeyList;
typedef QVector< tPScoreInfo* >			tPScoreInfoVector;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tBetMsg
{
	QString		pid;
	QString		strName;

	QString		strContent;

	int			flag;


	tBetMsg()
	{
		flag = -1;
	}
	~tBetMsg()
	{

	}
	tBetMsg(const tBetMsg& other)
	{
		tBetMsg::operator = (other);
	}
	const tBetMsg& operator = (const tBetMsg& other)
	{
		if (&other != this)
		{
			pid = other.pid;
			strName = other.strName;

			strContent = other.strContent;

			flag = other.flag;
		}

		return (*this);
	}
};

typedef QVector< tBetMsg >	tBetMsgVector;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tLoginParam
{
	QString			strHost;
	int				nPort;

	QString			strUser;
	QString			strPass;


	tLoginParam()
	{
		nPort = 0;
	}
	~tLoginParam()
	{

	}
	tLoginParam(const tLoginParam& other)
	{
		tLoginParam::operator = (other);
	}
	const tLoginParam& operator = (const tLoginParam& other)
	{
		if (&other != this)
		{
			strHost = other.strHost;
			nPort = other.nPort;

			strUser = other.strUser;
			strPass = other.strPass;
		}

		return (*this);
	}
};

typedef QVector< tLoginParam >	tLoginParamVector;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


