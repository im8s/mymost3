#ifndef ROBOTVMODEL_H
#define ROBOTVMODEL_H

#include "ARobot.h"

#include <QAbstractTableModel>


class RobotTVModel : public QAbstractTableModel
{
	Q_OBJECT

public:
	RobotTVModel(const QStringList &headList, tRobotVector* rbtColl, QObject *parent = nullptr);
	~RobotTVModel();

	enum
	{
		ID_Role			=	0,
		Name_Role		=	1,
		Status_Role		=	2,
		Bet_Role		=	3,
	};

	int rowCount(const QModelIndex& = QModelIndex()) const override;
	int columnCount(const QModelIndex& = QModelIndex()) const override;
	QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
	QVariant data(const QModelIndex &index, int role) const override;

	Qt::ItemFlags flags(const QModelIndex& index) const override;

	void sort(int column, Qt::SortOrder order);
	bool lessThan(const QVariant &left, const QVariant &right) const;
	
	tRobot* getRowData(int nRow);
	
	void clear();

signals:
	void signalRecvhandleData();

public slots:
	void onRefreshModel();

private:
	void handleData(tRobotVector* rbtColl);

private:
	QStringList			m_strlstHHead;
	
	tRobotVector*		m_rbtColl = nullptr;

	int					m_nSortCol = 0;
	Qt::SortOrder		m_nSortOrder = Qt::AscendingOrder;
};


#endif // ROBOTVMODEL_H

