#include "PScoreTVModel.h"
#include <QColor>


PScoreTVModel::PScoreTVModel(const QStringList &headList, tPScoreInfoVector* psiColl, QObject *parent)
	:	QAbstractTableModel(parent)
{
	m_strlstHHead = headList;

	m_psiColl = psiColl;
}

PScoreTVModel::~PScoreTVModel()
{
}

int PScoreTVModel::rowCount(const QModelIndex &) const
{
	return m_psiColl->size();
}

int PScoreTVModel::columnCount(const QModelIndex &) const
{
	return m_strlstHHead.size();
}

QVariant PScoreTVModel::headerData(int section, Qt::Orientation orientation, int role) const
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

QVariant PScoreTVModel::data(const QModelIndex &index, int role) const
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
		tPScoreInfoVector* psiColl = m_psiColl;

		if (psiColl->size() > index.row())
		{
			int row = index.row();

			if (row >= 0 && row < psiColl->size())
			{
				const tPScoreInfo* psi = psiColl->at(row);

				int col = index.column();

				if (PID_Role == col)
					return psi->pid;
				else if (Name_Role == col)
					return psi->strName;
				else if (TotalScore_Role == col)
					return QString::number(psi->fTotalScore,'f',2);
				else if (Bet_Role == col)
					return psi->strBetStr;

				else if (AccScore_Role == col)
					return QString::number(psi->fAccScore, 'f', 2);
				else if (AccWScore_Role == col)
					return QString::number(psi->fAccWScore, 'f', 2);
				else if (AccLScore_Role == col)
					return QString::number(psi->fAccLScore, 'f', 2);
				else if (AccPayment_Role == col)
					return QString::number(psi->fAccPayment, 'f', 2);

				else if (ThisScore_Role == col)
					return QString::number(psi->fThisScore, 'f', 2);
				else if (ThisWScore_Role == col)
					return QString::number(psi->fThisWScore, 'f', 2);
				else if (ThisLScore_Role == col)
					return QString::number(psi->fThisLScore, 'f', 2);
				else if (ThisPayment_Role == col)
					return QString::number(psi->fThisPayment, 'f', 2);

				else if (AccTurnNum_Role == col)
					return QString::number(psi->nAccTurnNum);
				else if (AccLotNum_Role == col)
					return QString::number(psi->nAccLotNum);
				else if (AccWLotNum_Role == col)
					return QString::number(psi->nAccWLotNum);
				else if (AccLLotNum_Role == col)
					return QString::number(psi->nAccLLotNum);

				else if (ThisLotNum_Role == col)
					return QString::number(psi->nThisLotNum);
				else if (ThisWLotNum_Role == col)
					return QString::number(psi->nThisWLotNum);
				else if (ThisLLotNum_Role == col)
					return QString::number(psi->nThisLLotNum);
				else if (Type_Role == col)
					return QString::number(psi->nType);
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

Qt::ItemFlags PScoreTVModel::flags(const QModelIndex& index) const
{
	if (!index.isValid())
		return QAbstractItemModel::flags(index);
	return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

void PScoreTVModel::sort(int col, Qt::SortOrder order)
{
	if (m_psiColl->isEmpty() || col < 0 || col >= columnCount())
		return;

	m_nSortCol = col;
	m_nSortOrder = order;

	const bool is_asc = (order == Qt::AscendingOrder);
	
	std::sort(m_psiColl->begin(), m_psiColl->end(),
		[col, is_asc, this](const tPScoreInfo* left, const tPScoreInfo* right)
	{
		QVariant left_val;
		QVariant right_val;

		if (PID_Role == col)
		{
			left_val = left->pid;
			right_val = right->pid;
		}
		else if (Name_Role == col)
		{
			left_val = left->strName;
			right_val = right->strName;
		}
		else if (TotalScore_Role == col)
		{
			left_val = left->fTotalScore;
			right_val = right->fTotalScore;
		}
		else if (Bet_Role == col)
		{
			left_val = left->strBetStr;
			right_val = right->strBetStr;
		}

		else if (AccScore_Role == col)
		{
			left_val = left->fAccScore;
			right_val = right->fAccScore;
		}
		else if (AccWScore_Role == col)
		{
			left_val = left->fAccWScore;
			right_val = right->fAccWScore;
		}
		else if (AccLScore_Role == col)
		{
			left_val = left->fAccLScore;
			right_val = right->fAccLScore;
		}
		else if (AccPayment_Role == col)
		{
			left_val = left->fAccPayment;
			right_val = right->fAccPayment;
		}

		else if (ThisScore_Role == col)
		{
			left_val = left->fThisScore;
			right_val = right->fThisScore;
		}
		else if (ThisWScore_Role == col)
		{
			left_val = left->fThisWScore;
			right_val = right->fThisWScore;
		}
		else if (ThisLScore_Role == col)
		{
			left_val = left->fThisLScore;
			right_val = right->fThisLScore;
		}
		else if (ThisPayment_Role == col)
		{
			left_val = left->fThisPayment;
			right_val = right->fThisPayment;
		}

		else if (AccTurnNum_Role == col)
		{
			left_val = left->nAccTurnNum;
			right_val = right->nAccTurnNum;
		}
		else if (AccLotNum_Role == col)
		{
			left_val = left->nAccLotNum;
			right_val = right->nAccLotNum;
		}
		else if (AccWLotNum_Role == col)
		{
			left_val = left->nAccWLotNum;
			right_val = right->nAccWLotNum;
		}
		else if (AccLLotNum_Role == col)
		{
			left_val = left->nAccLLotNum;
			right_val = right->nAccLLotNum;
		}

		else if (ThisLotNum_Role == col)
		{
			left_val = left->nThisLotNum;
			right_val = right->nThisLotNum;
		}
		else if (ThisWLotNum_Role == col)
		{
			left_val = left->nThisWLotNum;
			right_val = right->nThisWLotNum;
		}
		else if (ThisLLotNum_Role == col)
		{
			left_val = left->nThisLLotNum;
			right_val = right->nThisLLotNum;
		}
		else if (Type_Role == col)
		{
			left_val = left->nType;
			right_val = right->nType;
		}

		else
		{
			return is_asc;
		}
		
		return is_asc
			? lessThan(left_val, right_val)
			: lessThan(right_val, left_val);
	});
	
	dataChanged(index(0, 0), index(m_psiColl->count() - 1, columnCount() - 1));
}

bool PScoreTVModel::lessThan(const QVariant &left, const QVariant &right) const
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

tPScoreInfo* PScoreTVModel::getRowData(int nRow)
{
	const tPScoreInfoVector* psiColl = m_psiColl;

	if (nRow >= 0 && nRow < psiColl->size())
	{
		tPScoreInfo* psi = psiColl->at(nRow);
		return psi;
	}

	return nullptr;
}

void PScoreTVModel::clear()
{
	m_psiColl->clear();
}

void PScoreTVModel::onRefreshModel()
{
	beginResetModel();
	endResetModel();

	sort(m_nSortCol, m_nSortOrder);
}

void PScoreTVModel::handleData(tPScoreInfoVector* psiColl)
{
	beginResetModel();
	{
		m_psiColl = psiColl;
	}
	endResetModel();

	sort(m_nSortCol, m_nSortOrder);
}


