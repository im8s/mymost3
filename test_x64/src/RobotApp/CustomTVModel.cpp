#include "CustomTVModel.h"
#include <QColor>


CustomTVModel::CustomTVModel(const QStringList &headList, ARobotVector* rbtColl, QObject *parent)
	:	QAbstractTableModel(parent)
{
	m_strlstHHead = headList;
	m_rbtColl = rbtColl;

	m_nRow = m_rbtColl->size();
	m_nColumn = headList.size();
}

CustomTVModel::~CustomTVModel()
{
}

int CustomTVModel::rowCount(const QModelIndex &) const
{
	return m_nRow;
}

int CustomTVModel::columnCount(const QModelIndex &) const
{
	return m_nColumn;
}

QVariant CustomTVModel::headerData(int section, Qt::Orientation orientation, int role) const
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

QVariant CustomTVModel::data(const QModelIndex &index, int role) const
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
		ARobotVector* rbtColl = m_rbtColl;

		if (rbtColl->size() > index.row())
		{
			{
				const ARobot* arbt = rbtColl->at(index.row());

				const tRobot& rbt = arbt->getRobot();

				int col = index.column();

				if (ID_Role == col)
					return QString::number(rbt.id);
				else if (Name_Role == col)
					return rbt.strUser;
				else if (Bet_Role == col)
					return rbt.strBet;
				else if (Status_Role == col)
					return rbt.getRSString();
				
				return "";
			}
		}

		return QVariant();
	}
	case Qt::CheckStateRole:
	{
		return QVariant(); // 返回勾选框，如果返回QVariant()就没有勾选框
	}
	default:
		return QVariant();
	}
}

Qt::ItemFlags CustomTVModel::flags(const QModelIndex& index) const
{
	if (!index.isValid())
		return QAbstractItemModel::flags(index);
	return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void CustomTVModel::sort(int col, Qt::SortOrder order)
{
	if (m_rbtColl->isEmpty() || col < 0 || col >= columnCount())
		return;
	
	const bool is_asc = (order == Qt::AscendingOrder);
	
	std::sort(m_rbtColl->begin(), m_rbtColl->end(),
		[col, is_asc, this](const ARobot* left, const ARobot* right) 
	{
		QVariant left_val;
		QVariant right_val;

		if (ID_Role == col)
		{
			left_val = left->getRobot().id;
			right_val = right->getRobot().id;
		}
		else if (Name_Role == col)
		{
			left_val = left->getRobot().strUser;
			right_val = right->getRobot().strUser;
		}
		else if (Status_Role == col)
		{
			left_val = left->getRobot().getRSString();
			right_val = right->getRobot().getRSString();
		}
		else if (Bet_Role == col)
		{
			left_val = left->getRobot().strBet;
			right_val = right->getRobot().strBet;
		}
		else
		{
			return is_asc;
		}
		
		return is_asc
			? lessThan(left_val, right_val)
			: lessThan(right_val, left_val);
	});
	
	dataChanged(index(0, 0), index(m_rbtColl->count() - 1, columnCount() - 1));
}

bool CustomTVModel::lessThan(const QVariant &left, const QVariant &right) const
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
	
	//return left.toString().compare(right.toString(), cs) < 0;
}

ARobot* CustomTVModel::getRowData(int nRow)
{
	if (nRow < 0 || nRow >= m_rbtColl->size())
	{
		return nullptr;
	}

	return m_rbtColl->at(nRow);
}

void CustomTVModel::clear()
{
	m_rbtColl->clear();
	m_nRow = 0;
	m_nColumn = 0;
}

void CustomTVModel::onRefreshModel()
{
	beginResetModel();
	m_nRow = m_rbtColl->size();
	endResetModel();
}

void CustomTVModel::handleData(ARobotVector* rbtColl)
{
	beginResetModel();
	{
		m_rbtColl = rbtColl;
		m_nRow = rbtColl->size();
		m_nColumn = m_nRow > 0 ? m_strlstHHead.size() : 0;
	}
	endResetModel();
}


