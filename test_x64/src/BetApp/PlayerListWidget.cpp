#include "PlayerListWidget.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include "ToolFunc.h"
#include "PScoreTVModel.h"

#include <QMenu>


PlayerListWidget::PlayerListWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	QObject::connect(BCMGR, SIGNAL(onRefreshPScoreInfoModel()), this, SLOT(onRefreshModel()));

	{
		QStringList headerText;
		headerText << ZN_STR("ID") << ZN_STR("昵称") << ZN_STR("总积分") << ZN_STR("下注内容")
			<< ZN_STR("累积总分") << ZN_STR("累积赢分") << ZN_STR("累积输分") << ZN_STR("累积本金")
			<< ZN_STR("本轮总分") << ZN_STR("本轮赢分") << ZN_STR("本轮输分") << ZN_STR("本轮本金")
			<< ZN_STR("累积盘数") << ZN_STR("累积注数") << ZN_STR("累积赢注数") << ZN_STR("累积输注数")
			<< ZN_STR("本轮注数") << ZN_STR("本轮赢注数") << ZN_STR("本轮输注数")
			<< ZN_STR("用户类型");

		model = new PScoreTVModel(headerText, BCMGR->getPScoreInfoVector(), ui.tvlist);
		{
			QObject::connect(BCMGR, SIGNAL(onRefreshPScoreInfoModel()), model, SLOT(onRefreshModel()));

			ui.tvlist->setEditTriggers(QAbstractItemView::NoEditTriggers);
			ui.tvlist->setSelectionBehavior(QAbstractItemView::SelectRows);
			ui.tvlist->setSelectionMode(QAbstractItemView::ExtendedSelection);
			//ui.tvlist->verticalHeader()->setVisible(false); //隐藏列表头 
			//ui.tvlist->horizontalHeader()->setVisible(false); //隐藏行表头

			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Stretch);
			//ui.tvlist->resizeColumnsToContents();
			//ui.tvlist->resizeRowsToContents();

			ui.tvlist->setGridStyle(Qt::SolidLine);
			ui.tvlist->horizontalHeader()->setStretchLastSection(true);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

			ui.tvlist->setSortingEnabled(true); // 可以按列来排序

			//ui.tvlist->horizontalHeader()->setDefaultAlignment(Qt::AlignHCenter);
			//ui.tvlist->horizontalHeader()->setFont(QFont("Times", 10, QFont::Bold));
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

		ui.tvlist->setContextMenuPolicy(Qt::CustomContextMenu); // 可以自定义右键菜单

		m_menu = new QMenu(this);
		QAction *processAct = new QAction(QStringLiteral("进程列表信息"), m_menu);
		QAction *windowAppsAct = new QAction(QStringLiteral("窗口应用列表信息"), m_menu);
		m_menu->addAction(processAct);
		m_menu->addAction(windowAppsAct);

		connect(ui.tvlist, SIGNAL(customContextMenuRequested(const QPoint&)),
			this, SLOT(slotShowContextMenu(const QPoint&)));
	}
}

PlayerListWidget::~PlayerListWidget()
{
	delete model;
	delete m_menu;
}

void PlayerListWidget::slotShowContextMenu(const QPoint& point)
{
	QModelIndex index = ui.tvlist->indexAt(point);
	if (index.isValid())
	{
		m_menu->exec(QCursor::pos());
	}
}

void PlayerListWidget::onRefreshModel()
{
	if (model)
		model->onRefreshModel();
}
