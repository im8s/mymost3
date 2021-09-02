#include "LotteryDataTVModel.h"
#include <QColor>


LotteryDataTVModel::LotteryDataTVModel(const QStringList &headList, tLotteryMap* lotColl, QObject *parent)
	:	QAbstractTableModel(parent)
{
	m_strlstHHead = headList;

	m_lotColl = lotColl;
	m_keyColl = m_lotColl->keys();

	m_nRow = lotColl->size();
	m_nColumn = headList.size();

	sort(m_nSortCol, m_nSortOrder);
}

LotteryDataTVModel::~LotteryDataTVModel()
{
}

int LotteryDataTVModel::rowCount(const QModelIndex &) const
{
	return m_nRow;
}

int LotteryDataTVModel::columnCount(const QModelIndex &) const
{
	return m_nColumn;
}

QVariant LotteryDataTVModel::headerData(int section, Qt::Orientation orientation, int role) const
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

QVariant LotteryDataTVModel::data(const QModelIndex &index, int role) const
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
		const tLotteryMap* lotColl = m_lotColl;

		if (lotColl->size() > index.row())
		{
			int row = index.row();

			const tLotKeyList& pikColl = m_keyColl;

			if (row >= 0 && row < pikColl.size())
			{
				qint32 key = pikColl.at(row);

				if (lotColl->contains(key))
				{
					const tLottery* lot = lotColl->value(key);

					int col = index.column();

					if (Periods_Role == col)
						return QString::number(lot->nPeriods);
					else if (OpenTime_Role == col)
						return lot->strOpenTime;
					else if (_3X9_Role == col)
						return lot->strOpenContent;
					else if (_28_Role == col)
						return lot->asSum();

					else if (OpenContent_Role == col)
						return lot->asResult();
					else if (WinLost_Role == col)
						return "";
					else if (Remarks_Role == col)
						return "";
					else if (LotNumber_Role == col)
						return "";
				}
			}
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

Qt::ItemFlags LotteryDataTVModel::flags(const QModelIndex& index) const
{
	if (!index.isValid())
		return QAbstractItemModel::flags(index);
	return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void LotteryDataTVModel::sort(int col, Qt::SortOrder order)
{
	if (m_lotColl->isEmpty() || col < 0 || col >= columnCount())
		return;

	m_nSortCol = col;
	m_nSortOrder = order;

	const bool is_asc = (order == Qt::AscendingOrder);
	
	std::sort(m_keyColl.begin(), m_keyColl.end(),
		[col, is_asc, this](qint32 lkey, qint32 rkey)
	{
		const tLottery* left = m_lotColl->value(lkey);
		const tLottery* right = m_lotColl->value(rkey);

		QVariant left_val;
		QVariant right_val;

		if (Periods_Role == col)
		{
			left_val = left->nPeriods;
			right_val = right->nPeriods;
		}
		else if (OpenTime_Role == col)
		{
			left_val = left->strOpenTime;
			right_val = right->strOpenTime;
		}
		else if (_3X9_Role == col)
		{
			left_val = left->strOpenContent;
			right_val = right->strOpenContent;
		}
		else if (_28_Role == col)
		{
			left_val = left->asSum();
			right_val = right->asSum();
		}

		else if (OpenContent_Role == col)
		{
			left_val = left->asResult();
			right_val = right->asResult();
		}
		/*else if (WinLost_Role == col)
		{
			left_val = left->fAccWScore;
			right_val = right->fAccWScore;
		}
		else if (Remarks_Role == col)
		{
			left_val = left->fAccLScore;
			right_val = right->fAccLScore;
		}
		else if (LotNumber_Role == col)
		{
			left_val = left->fAccPayment;
			right_val = right->fAccPayment;
		}*/
		else
		{
			return is_asc;
		}
		
		return is_asc
			? lessThan(left_val, right_val)
			: lessThan(right_val, left_val);
	});
	
	dataChanged(index(0, 0), index(m_lotColl->count() - 1, columnCount() - 1));
}

bool LotteryDataTVModel::lessThan(const QVariant &left, const QVariant &right) const
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

tLottery* LotteryDataTVModel::getRowData(int nRow)
{
	const tLotteryMap* lotColl = m_lotColl;
	const tLotKeyList& pikColl = m_keyColl;

	if (nRow >= 0 && nRow < pikColl.size())
	{
		qint32 key = pikColl.at(nRow);

		if (lotColl->contains(key))
		{
			tLottery* psi = lotColl->value(key);
			return psi;
		}
	}

	return nullptr;
}

void LotteryDataTVModel::clear()
{
	m_lotColl->clear();
	m_keyColl.clear();

	m_nRow = 0;
	m_nColumn = 0;
}

void LotteryDataTVModel::onRefreshModel()
{
	beginResetModel();
	m_keyColl = m_lotColl->keys();
	m_nRow = m_lotColl->size();

	sort(m_nSortCol, m_nSortOrder);
	endResetModel();
}

void LotteryDataTVModel::handleData(tLotteryMap* lotColl)
{
	beginResetModel();
	{
		m_lotColl = lotColl;
		m_keyColl = m_lotColl->keys();

		m_nRow = lotColl->size();
		m_nColumn = m_nRow > 0 ? m_strlstHHead.size() : 0;

		sort(m_nSortCol, m_nSortOrder);
	}
	endResetModel();
}


