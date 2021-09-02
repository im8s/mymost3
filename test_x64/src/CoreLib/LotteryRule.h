#pragma once

#include "corelib_global.h"

#include "gdata.h"
#include "ToolFunc.h"

#include <QVector>
#include <QMap>


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tQuota
{
	bool		bUseThis;
	int			nAmount;

	int			nType;

	tQuota()
	{
		bUseThis = true;

		nAmount = 0;
		nType = -1;
	}
	~tQuota()
	{

	}
	tQuota(const tQuota& other)
	{
		tQuota::operator = (other);
	}
	const tQuota& operator = (const tQuota& other)
	{
		if (&other != this)
		{
			bUseThis = other.bUseThis;

			nAmount = other.nAmount;
			nType = other.nType;
		}

		return (*this);
	}
};

typedef QVector< tQuota >		tQuotaVector;
typedef QMap< int, tQuota >		tQuotaMap;

//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tForbid
{
	bool		bUseForbid;

	bool		bUseThis;
	int			nAmount;

	int			nType;

	tForbid()
	{
		bUseForbid = true;

		bUseThis = false;
		nAmount = 0;

		nType = -1;
	}
	~tForbid()
	{

	}
	tForbid(const tForbid& other)
	{
		tForbid::operator = (other);
	}
	const tForbid& operator = (const tForbid& other)
	{
		if (&other != this)
		{
			bUseForbid = other.bUseForbid;

			bUseThis = other.bUseThis;
			nAmount = other.nAmount;

			nType = other.nType;
		}

		return (*this);
	}
};

typedef QVector< tForbid >		tForbidVector;
typedef QMap< int, tForbid >	tForbidMap;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

#define USE_CONTAINER		0

struct CORELIB_EXPORT tLotQuota
{
#ifdef USE_CONTAINER
	tQuotaVector	qcoll;

	bool		bUseSDGross;
#else
	tQuota		minAllQuota;

	tQuota		maxSDQuota;
	bool		bUseSDGross;

	tQuota		maxBSOEQuota;
	tQuota		maxGrpQuota;
	tQuota		maxMMQuota;

	tQuota		max3SameQuota;
	tQuota		max2SameQuota;
	tQuota		maxContQuota;

	tQuota		maxAllQuota;
#endif

	tLotQuota()
	{
		bUseSDGross = false;
	}
	~tLotQuota()
	{

	}
	tLotQuota(const tLotQuota& other)
	{
		tLotQuota::operator = (other);
	}
	const tLotQuota& operator = (const tLotQuota& other)
	{
		if (&other != this)
		{
#ifdef USE_CONTAINER
			qcoll = other.qcoll;
			bUseSDGross = other.bUseSDGross;
#else
			minAllQuota = other.minAllQuota;

			maxSDQuota = other.maxSDQuota;
			bUseSDGross = other.bUseSDGross;

			maxBSOEQuota = other.maxBSOEQuota;
			maxGrpQuota = other.maxGrpQuota;
			maxMMQuota = other.maxMMQuota;

			max3SameQuota = other.max3SameQuota;
			max2SameQuota = other.max2SameQuota;
			maxContQuota = other.maxContQuota;

			maxAllQuota = other.maxAllQuota;
#endif
		}

		return (*this);
	}

	bool checkRules(const tLotJudge& lj, const tBetInfo& bi, int nSDNum, 
						int nSDMount, int nTotalMount, QString& strMsg);

	QString asString()
	{
		QString str = ZN_STR("");

		return str;
	}
};

//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tLotForbid
{
#ifdef USE_CONTAINER
	tForbidVector	fcoll;
#else
	tForbid		killGrpForbid;
	tForbid		reverseGrpForbid;
	tForbid		syntropyGrpForbid;

	tForbid		reverseBSOEForbid;
#endif

	tLotForbid()
	{
		
	}
	~tLotForbid()
	{

	}
	tLotForbid(const tLotForbid& other)
	{
		tLotForbid::operator = (other);
	}
	const tLotForbid& operator = (const tLotForbid& other)
	{
		if (&other != this)
		{
#ifdef USE_CONTAINER
			fcoll = other.fcoll;
#else
			killGrpForbid = other.killGrpForbid;
			reverseGrpForbid = other.reverseGrpForbid;
			syntropyGrpForbid = other.syntropyGrpForbid;

			reverseBSOEForbid = other.reverseBSOEForbid;
#endif
		}

		return (*this);
	}

	bool checkRules(const tLotJudge& lj, const tBetInfo& bi, int nSDNum, 
						int nSDMount, int nTotalMount, QString& strMsg);

	QString asString()
	{
		QString str = ZN_STR("");

		return str;
	}
};

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT LotteryRule
{
public:
	LotteryRule();
	~LotteryRule();
	LotteryRule(const LotteryRule& other);
	const LotteryRule& operator = (const LotteryRule& other);

	tLotQuota& getLotteryQuata()
	{
		return m_lotQuota;
	}
	const tLotQuota& getLotteryQuata() const
	{
		return m_lotQuota;
	}

	tLotForbid& getLotteryForbid()
	{
		return m_lotForbid;
	}
	const tLotForbid& getLotteryForbid() const
	{
		return m_lotForbid;
	}

	bool getSDLimit()
	{
		return m_bUseSDLimit;
	}
	bool getSDLimit() const
	{
		return m_bUseSDLimit;
	}
	void setSDLimit(bool b)
	{
		m_bUseSDLimit = b;
	}

	int getMaxSDDiffNum()
	{
		return m_nMaxSDDiffNum;
	}
	int getMaxSDDiffNum() const
	{
		return m_nMaxSDDiffNum;
	}
	void setMaxSDDiffNum(int n)
	{
		m_nMaxSDDiffNum = n;
	}

	bool getHintInvalid()
	{
		return m_bHintInvalid;
	}
	bool getHintInvalid() const
	{
		return m_bHintInvalid;
	}
	void setHintInvalid(bool b)
	{
		m_bHintInvalid = b;
	}

	bool getSaveScreenshot()
	{
		return m_bSaveScreenshot;
	}
	bool getSaveScreenshot() const
	{
		return m_bSaveScreenshot;
	}
	void setSaveScreenshot(bool b)
	{
		m_bSaveScreenshot = b;
	}

	bool checkRules(const tLotJudge& lj, const tBetInfo& bi, QString& strMsg);

protected:
	void toDefault();

private:
	tLotQuota		m_lotQuota;
	tLotForbid		m_lotForbid;

	bool			m_bUseSDLimit;
	int				m_nMaxSDDiffNum;

	bool			m_bHintInvalid;
	bool			m_bSaveScreenshot;
};

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



