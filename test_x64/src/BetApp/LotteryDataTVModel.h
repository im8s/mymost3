#ifndef LOTTERYDATATVMODEL_H
#define LOTTERYDATATVMODEL_H

#include "gdata.h"

#include <QAbstractTableModel>


class LotteryDataTVModel : public QAbstractTableModel
{
	Q_OBJECT

public:
	LotteryDataTVModel(const QStringList &headList, tLotteryMap* data, QObject *parent = nullptr);
	~LotteryDataTVModel();

	enum
	{
		Periods_Role			=	0,
		OpenTime_Role			=	1,
		_3X9_Role				=	2,
		_28_Role				=	3,

		OpenContent_Role		=	4,
		WinLost_Role			=	5,
		Remarks_Role			=	6,
		LotNumber_Role			=	7,
	};

	int rowCount(const QModelIndex& = QModelIndex()) const override;
	int columnCount(const QModelIndex& = QModelIndex()) const override;
	QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
	QVariant data(const QModelIndex &index, int role) const override;

	Qt::ItemFlags flags(const QModelIndex& index) const override;

	void sort(int column, Qt::SortOrder order);
	bool lessThan(const QVariant &left, const QVariant &right) const;
	
	tLottery* getRowData(int nRow);
	
	void clear();

signals:
	void signalRecvhandleData();

public slots:
	void handleData(tLotteryMap* lotColl);

	void onRefreshModel();

private:
	int m_nRow;
	int m_nColumn;
	
	QStringList			m_strlstHHead;
	
	tLotteryMap*		m_lotColl;
	tLotKeyList			m_keyColl;

	int					m_nSortCol = 0;
	Qt::SortOrder		m_nSortOrder = Qt::DescendingOrder;
};


#endif // LOTTERYDATATVMODEL_H

