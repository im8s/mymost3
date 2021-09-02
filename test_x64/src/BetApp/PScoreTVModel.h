#ifndef PSCORETVMODEL_H
#define PSCORETVMODEL_H

#include "gdata.h"

#include <QAbstractTableModel>


class PScoreTVModel : public QAbstractTableModel
{
	Q_OBJECT

public:
	PScoreTVModel(const QStringList &headList, tPScoreInfoVector* psiColl, QObject *parent = nullptr);
	~PScoreTVModel();

	enum
	{
		PID_Role			=	0,
		Name_Role			=	1,
		TotalScore_Role		=	2,
		Bet_Role			=	3,

		AccScore_Role		=	4,
		AccWScore_Role		=	5,
		AccLScore_Role		=	6,
		AccPayment_Role		=	7,

		ThisScore_Role		=	8,
		ThisWScore_Role		=	9,
		ThisLScore_Role		=	10,
		ThisPayment_Role	=	11,

		AccTurnNum_Role		=	12,
		AccLotNum_Role		=	13,
		AccWLotNum_Role		=	14,
		AccLLotNum_Role		=	15,

		ThisLotNum_Role		=	16,
		ThisWLotNum_Role	=	17,
		ThisLLotNum_Role	=	18,

		Type_Role			=	19,
	};

	int rowCount(const QModelIndex& = QModelIndex()) const override;
	int columnCount(const QModelIndex& = QModelIndex()) const override;
	QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
	QVariant data(const QModelIndex &index, int role) const override;

	Qt::ItemFlags flags(const QModelIndex& index) const override;

	void sort(int column, Qt::SortOrder order);
	bool lessThan(const QVariant &left, const QVariant &right) const;
	
	tPScoreInfo* getRowData(int nRow);
	
	void clear();

signals:
	void signalRecvhandleData();

public slots:
	void onRefreshModel();

private:
	void handleData(tPScoreInfoVector* rbtColl);

private:
	QStringList			m_strlstHHead;
	
	tPScoreInfoVector*	m_psiColl;

	int					m_nSortCol = 0;
	Qt::SortOrder		m_nSortOrder = Qt::AscendingOrder;
};


#endif // PSCORETVMODEL_H

