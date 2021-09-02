#include "RobotTVModel.h"

#include <QColor>


RobotTVModel::RobotTVModel(const QStringList &headList, tRobotVector* rbtColl, QObject *parent)
	:	QAbstractTableModel(parent)
{
	m_strlstHHead = headList;
	
	handleData(rbtColl);
}

RobotTVModel::~RobotTVModel()
{
}

int RobotTVModel::rowCount(const QModelIndex &) const
{
	return m_rbtColl->size();
}

int RobotTVModel::columnCount(const QModelIndex &) const
{
	return m_strlstHHead.size();
}

QVariant RobotTVModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	if (role == Qt::DisplayRole && orientation == Qt::Horizontal)
	{
		if (section < m_strlstHHead.size())
		{
			return m_strlstHHead[section];
		}
	}

	return QAbstractItemModel::headerData(section, orientation, role);
}

QVariant RobotTVModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid())
		return QVariant();
	
	switch (role)
	{
	case Qt::TextColorRole:
		return QColor(Qt::black);
	case Qt::TextAlignmentRole:
		return QVariant(Qt::AlignHCenter | Qt::AlignVCenter);
	case Qt::DisplayRole:
	{
		const tRobotVector* rbtColl = m_rbtColl;

		int row = index.row();
		if (rbtColl->size() > row)
		{
			const tRobot* rbt = rbtColl->at(row);

			int col = index.column();

			if (ID_Role == col)
				return rbt->pid;
			else if (Name_Role == col)
				return rbt->strUser;
			else if (Bet_Role == col)
				return rbt->strBet;
			else if (Status_Role == col)
				return rbt->getRSString();

			return "";
		}

		return QVariant();
	}
	case Qt::CheckStateRole:
	{
		return QVariant();
	}
	default:
		return QVariant();
	}
}

Qt::ItemFlags RobotTVModel::flags(const QModelIndex& index) const
{
	if (!index.isValid())
		return QAbstractItemModel::flags(index);
	return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void RobotTVModel::sort(int col, Qt::SortOrder order)
{
	if (m_rbtColl->isEmpty() || col < 0 || col >= columnCount())
		return;

	m_nSortCol = col;
	m_nSortOrder = order;
	
	const bool is_asc = (order == Qt::AscendingOrder);
	
	std::sort(m_rbtColl->begin(), m_rbtColl->end(),
		[col, is_asc, this](const tRobot* left, const tRobot* right)
	{
		QVariant left_val;
		QVariant right_val;

		if (ID_Role == col)
		{
			left_val = left->pid;
			right_val = right->pid;
		}
		else if (Name_Role == col)
		{
			left_val = left->strUser;
			right_val = right->strUser;
		}
		else if (Status_Role == col)
		{
			left_val = left->getRSString();
			right_val = right->getRSString();
		}
		else if (Bet_Role == col)
		{
			left_val = left->strBet;
			right_val = right->strBet;
		}
		else
		{
			return is_asc;
		}
		
		return is_asc
			? lessThan(left_val, right_val)
			: lessThan(right_val, left_val);
	});
	
	dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

bool RobotTVModel::lessThan(const QVariant &left, const QVariant &right) const
{
	if (left.userType() == QMetaType::UnknownType
		|| right.userType() == QMetaType::UnknownType)
		return false;

	switch (left.userType()) 
	{
	case QMetaType::Int:
		return left.toInt() < right.toInt();
	case QMetaType::UInt:
		return left.toUInt() < right.toUInt();
	case QMetaType::LongLong:
		return left.toLongLong() < right.toLongLong();
	case QMetaType::ULongLong:
		return left.toULongLong() < right.toULongLong();
	case QMetaType::Float:
		return left.toFloat() < right.toFloat();
	case QMetaType::Double:
		return left.toDouble() < right.toDouble();
	case QMetaType::QChar:
		return left.toChar() < right.toChar();
	case QMetaType::QDate:
		return left.toDate() < right.toDate();
	case QMetaType::QTime:
		return left.toTime() < right.toTime();
	case QMetaType::QDateTime:
		return left.toDateTime() < right.toDateTime();
	case QMetaType::QString: 
		break;
	default: 
		break;
	}
	
	return left.toString().localeAwareCompare(right.toString()) < 0;
}

tRobot* RobotTVModel::getRowData(int nRow)
{
	tRobotVector* rbtColl = m_rbtColl;

	if (nRow >= 0 && nRow < rbtColl->size())
	{
		return rbtColl->at(nRow);
	}

	return nullptr;
}

void RobotTVModel::clear()
{
	m_rbtColl->clear();
}

void RobotTVModel::onRefreshModel()
{
	beginResetModel();
	{
	}
	endResetModel();

	sort(m_nSortCol, m_nSortOrder);
}

void RobotTVModel::handleData(tRobotVector* rbtColl)
{
	beginResetModel();
	{
		m_rbtColl = rbtColl;
	}
	endResetModel();

	sort(m_nSortCol, m_nSortOrder);
}


