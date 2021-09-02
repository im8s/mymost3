#include "LotteryDataWidget.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include "ToolFunc.h"
#include "LotteryDataTVModel.h"

#include "gdata.h"

#include <QMenu>


LotteryDataWidget::LotteryDataWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	QObject::connect(ui.pbtnFetchLotteryData, SIGNAL(clicked()), this, SLOT(onClickedPBtnFetchLotteryData()));
	
	QObject::connect(BCMGR, SIGNAL(onRefreshLotteryInfoModel()), this, SLOT(onRefreshModel()));

	{
		QStringList headerText;
		headerText << ZN_STR("�ں�") << ZN_STR("����ʱ��") << ZN_STR("3x9")
			<< ZN_STR("28") << ZN_STR("�������") << ZN_STR("��Ӯ")
			<< ZN_STR("��ע") << ZN_STR("��������");

		model = new LotteryDataTVModel(headerText, BCMGR->getLotteryInfoMap(), ui.tvlist);
		{
			QObject::connect(BCMGR, SIGNAL(onRefreshLotteryInfoModel()), model, SLOT(onRefreshModel()));

			ui.tvlist->setEditTriggers(QAbstractItemView::NoEditTriggers);
			ui.tvlist->setSelectionBehavior(QAbstractItemView::SelectRows);
			ui.tvlist->setSelectionMode(QAbstractItemView::ExtendedSelection);
			//ui.tvlist->verticalHeader()->setVisible(false); //�����б�ͷ 
			//ui.tvlist->horizontalHeader()->setVisible(false); //�����б�ͷ

			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Stretch);
			ui.tvlist->resizeColumnsToContents();
			ui.tvlist->resizeRowsToContents();

			ui.tvlist->setGridStyle(Qt::SolidLine);
			ui.tvlist->horizontalHeader()->setStretchLastSection(true);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

			ui.tvlist->setSortingEnabled(true); // ���԰���������

			//ui.tvlist->horizontalHeader()->setDefaultAlignment(Qt::AlignHCenter);
			//ui.tvlist->horizontalHeader()->setFont(QFont("Times", 10, QFont::Bold));

			//ui.tvlist->horizontalHeader()->setSectionResizeMode(LotteryDataTVModel::OpenTime_Role, QHeaderView::ResizeMode::Fixed);
			ui.tvlist->setColumnWidth(LotteryDataTVModel::OpenTime_Role, 200);
		}

#if 0
		QSortFilterProxyModel *proxy = new QSortFilterProxyModel(ui.tvlist);
		proxy->setSourceModel(model);
		ui.tvlist->setModel(proxy);
#else
		ui.tvlist->setModel(model);
#endif

		//ui.tvlist->horizontalHeader()->setResizeMode(QHeaderView::Stretch);
		//ui.tvlist->horizontalHeader()->setSectionResizeMode(RobotTVModel::ID_Role, QHeaderView::ResizeMode::Fixed);
		//ui.tvlist->setColumnWidth(RobotTVModel::ID_Role, 100);

		//ui.tvlist->setContextMenuPolicy(Qt::CustomContextMenu); // �����Զ����Ҽ��˵�

		//m_menu = new QMenu(this);
		//QAction *processAct = new QAction(QStringLiteral("�����б���Ϣ"), m_menu);
		//QAction *windowAppsAct = new QAction(QStringLiteral("����Ӧ���б���Ϣ"), m_menu);
		//m_menu->addAction(processAct);
		//m_menu->addAction(windowAppsAct);

		//connect(ui.tvlist, SIGNAL(customContextMenuRequested(const QPoint&)),
		//	this, SLOT(slotShowContextMenu(const QPoint&)));
	}
}

LotteryDataWidget::~LotteryDataWidget()
{
	delete model;
	delete m_menu;
}

void LotteryDataWidget::onClickedPBtnFetchLotteryData()
{
	ui.pbtnFetchLotteryData->setEnabled(false);
	BCMGR->lotteryRequest(2);
	ui.pbtnFetchLotteryData->setEnabled(true);
}

void LotteryDataWidget::slotShowContextMenu(const QPoint& point)
{
	QModelIndex index = ui.tvlist->indexAt(point);
	if (index.isValid())
	{
		m_menu->exec(QCursor::pos());
	}
}

void LotteryDataWidget::onRefreshModel()
{
	if (model)
		model->onRefreshModel();
}


