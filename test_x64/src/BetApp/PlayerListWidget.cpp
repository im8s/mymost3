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
		headerText << ZN_STR("ID") << ZN_STR("�ǳ�") << ZN_STR("�ܻ���") << ZN_STR("��ע����")
			<< ZN_STR("�ۻ��ܷ�") << ZN_STR("�ۻ�Ӯ��") << ZN_STR("�ۻ����") << ZN_STR("�ۻ�����")
			<< ZN_STR("�����ܷ�") << ZN_STR("����Ӯ��") << ZN_STR("�������") << ZN_STR("���ֱ���")
			<< ZN_STR("�ۻ�����") << ZN_STR("�ۻ�ע��") << ZN_STR("�ۻ�Ӯע��") << ZN_STR("�ۻ���ע��")
			<< ZN_STR("����ע��") << ZN_STR("����Ӯע��") << ZN_STR("������ע��")
			<< ZN_STR("�û�����");

		model = new PScoreTVModel(headerText, BCMGR->getPScoreInfoVector(), ui.tvlist);
		{
			QObject::connect(BCMGR, SIGNAL(onRefreshPScoreInfoModel()), model, SLOT(onRefreshModel()));

			ui.tvlist->setEditTriggers(QAbstractItemView::NoEditTriggers);
			ui.tvlist->setSelectionBehavior(QAbstractItemView::SelectRows);
			ui.tvlist->setSelectionMode(QAbstractItemView::ExtendedSelection);
			//ui.tvlist->verticalHeader()->setVisible(false); //�����б�ͷ 
			//ui.tvlist->horizontalHeader()->setVisible(false); //�����б�ͷ

			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Interactive);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Stretch);
			//ui.tvlist->resizeColumnsToContents();
			//ui.tvlist->resizeRowsToContents();

			ui.tvlist->setGridStyle(Qt::SolidLine);
			ui.tvlist->horizontalHeader()->setStretchLastSection(true);
			//ui.tvlist->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

			ui.tvlist->setSortingEnabled(true); // ���԰���������

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

		ui.tvlist->setContextMenuPolicy(Qt::CustomContextMenu); // �����Զ����Ҽ��˵�

		m_menu = new QMenu(this);
		QAction *processAct = new QAction(QStringLiteral("�����б���Ϣ"), m_menu);
		QAction *windowAppsAct = new QAction(QStringLiteral("����Ӧ���б���Ϣ"), m_menu);
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
