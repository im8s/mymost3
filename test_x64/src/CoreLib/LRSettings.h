#pragma once

#include "corelib_global.h"

#include "gdata.h"
#include "ToolFunc.h"

#include <QVector>
#include <QMap>


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tGrossAnd1314LRDef
{
	bool	bUseThis;

	int		nGross;
	float	fTimes;


	tGrossAnd1314LRDef()
	{
		bUseThis = false;

		nGross = 0;
		fTimes = 0;
	}
	~tGrossAnd1314LRDef()
	{

	}
	tGrossAnd1314LRDef(const tGrossAnd1314LRDef& other)
	{
		tGrossAnd1314LRDef::operator = (other);
	}
	const tGrossAnd1314LRDef& operator = (const tGrossAnd1314LRDef& other)
	{
		if (&other != this)
		{
			bUseThis = other.bUseThis;

			nGross = other.nGross;
			fTimes = other.fTimes;
		}

		return (*this);
	}
};

typedef QVector< tGrossAnd1314LRDef >	tGrossAnd1314LRDefVector;

//////////////////////////////////////////////////////////////////////////////

struct CORELIB_EXPORT tLikeCardLRDef
{
	bool	bUseThis;

	int		nType;
	float	fTimes;


	tLikeCardLRDef()
	{
		bUseThis = false;

		nType = -1;
		fTimes = 0;
	}
	~tLikeCardLRDef()
	{

	}
	tLikeCardLRDef(const tLikeCardLRDef& other)
	{
		tLikeCardLRDef::operator = (other);
	}
	const tLikeCardLRDef& operator = (const tLikeCardLRDef& other)
	{
		if (&other != this)
		{
			bUseThis = other.bUseThis;

			nType = other.nType;
			fTimes = other.fTimes;
		}

		return (*this);
	}
};

typedef QVector< tLikeCardLRDef >	tLikeCardLRDefVector;
typedef QMap< int, tLikeCardLRDef >	tLikeCardLRDefMap;

//////////////////////////////////////////////////////////////////////////////

typedef QMap< int, float >		Int2FltMap;

class CORELIB_EXPORT LRBase
{
public:
	LRBase()
	{

	}
	~LRBase()
	{

	}
};

//////////////////////////////////////////////////////////////////////////////

#define MAX_SUM_NUM		28

class CORELIB_EXPORT SumDigitalLR : public LRBase
{
public:
	SumDigitalLR();
	~SumDigitalLR();
	SumDigitalLR(const SumDigitalLR& other);
	const SumDigitalLR& operator = (const SumDigitalLR& other);

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr);

	QString getLRString();
	const QString getLRString() const;

	bool setLRString(const QString& str);

public:
	bool			m_bUseAccordLR;

	float			m_fAccordLR;
	Int2FltMap		m_lrColl;
};

//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT BigSmallAndOddEvenLR : public LRBase
{
public:
	BigSmallAndOddEvenLR();
	~BigSmallAndOddEvenLR();
	BigSmallAndOddEvenLR(const BigSmallAndOddEvenLR& other);
	const BigSmallAndOddEvenLR& operator = (const BigSmallAndOddEvenLR& other);

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, bool bUse890, float& flr);

public:
	float							m_fAccordLR;

	tGrossAnd1314LRDefVector		m_g1314Coll;
	tLikeCardLRDefVector			m_lcColl;
};

//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT GroupByLR : public LRBase
{
public:
	GroupByLR();
	~GroupByLR();
	GroupByLR(const GroupByLR& other);
	const GroupByLR& operator = (const GroupByLR& other);

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, bool bUse890, float& flr);

public:
	bool							m_bUseAlg1;

	float							m_fAccordLR;
	bool							m_bUse1314LR;
	float							m_f1314LR;

	float							m_fBigEvenAndSmallOddLR;
	float							m_fSmallEvenAndBigOddLR;

	tGrossAnd1314LRDefVector		m_g1314Coll;
	tLikeCardLRDefVector			m_lcColl;
};

//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT MinMaxByLR : public LRBase
{
public:
	MinMaxByLR();
	~MinMaxByLR();
	MinMaxByLR(const MinMaxByLR& other);
	const MinMaxByLR& operator = (const MinMaxByLR& other);

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr);

public:
	float			m_fAccordLR;
};

//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT LikeCardLR : public LRBase
{
public:
	LikeCardLR();
	~LikeCardLR();
	LikeCardLR(const LikeCardLR& other);
	const LikeCardLR& operator = (const LikeCardLR& other);

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, float& flr);

public:
	tLikeCardLRDefVector	m_lcColl;

	bool					m_bUse890;
};

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

class CORELIB_EXPORT LRSettings
{
public:
	LRSettings();
	~LRSettings();
	LRSettings(const LRSettings& other);
	const LRSettings& operator = (const LRSettings& other);

	SumDigitalLR& getSumDigitalLR()
	{
		return m_sdLR;
	}
	const SumDigitalLR& getSumDigitalLR() const
	{
		return m_sdLR;
	}

	BigSmallAndOddEvenLR& getBigSmallAndOddEvenLR()
	{
		return m_bsoeLR;
	}
	const BigSmallAndOddEvenLR& getBigSmallAndOddEvenLR() const
	{
		return m_bsoeLR;
	}

	GroupByLR& getGroupByLR()
	{
		return m_grpLR;
	}
	const GroupByLR& getGroupByLR() const
	{
		return m_grpLR;
	}

	MinMaxByLR& getMinMaxByLR()
	{
		return m_mmLR;
	}
	const MinMaxByLR& getMinMaxByLR() const
	{
		return m_mmLR;
	}

	LikeCardLR& getLikeCardLR()
	{
		return m_lcLR;
	}
	const LikeCardLR& getLikeCardLR() const
	{
		return m_lcLR;
	}

	bool checkRules(const tLotJudge& lj, QString& strMsg);

	bool getLostrate(const tLottery& lot, const tLotJudge& lj, int nTotalMount, float& flr);

protected:
	void toDefault();

private:
	SumDigitalLR				m_sdLR;
	BigSmallAndOddEvenLR		m_bsoeLR;
	GroupByLR					m_grpLR;
	MinMaxByLR					m_mmLR;
	LikeCardLR					m_lcLR;
};

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



