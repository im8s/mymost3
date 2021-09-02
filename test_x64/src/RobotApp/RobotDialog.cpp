#include "RobotDialog.h"

#include "ToolFunc.h"
#include "RobotApplication.h"
#include "RobotManager.h"

#include "RobotTVModel.h"

#include <QFileDialog>
#include <QCoreApplication>
#include <QMenu>
#include <QSortFilterProxyModel>


RobotDialog::RobotDialog(QWidget *parent)
    : QDialog(parent)
{
    ui.setupUi(this);

	//setWindowFlags(Qt::WindowMinMaxButtonsHint|Qt::WindowSystemMenuHint);
	setWindowFlags(windowFlags() | Qt::WindowMinMaxButtonsHint | Qt::WindowTitleHint);

	{
		QObject::connect(ui.pbtnSelFilePath, SIGNAL(clicked()), this, SLOT(onClickedPBtnSelFilePath()));
		QObject::connect(ui.pbtnStartup, SIGNAL(clicked()), this, SLOT(onClickedPBtnStartup()));

		QObject::connect(RMGR, SIGNAL(sigRobotTaskQuit()), this, SLOT(slotRobotTaskQuit()));

		ui.ledtNamePrefix->setText(ZN_STR("robot"));
		ui.ledtRobotNum->setText("1000");

		ui.ledtHostName->setText("192.168.59.130");
		//ui.ledtHostName->setText("localhost");
		ui.ledtPort->setText("8999");
		ui.ledtThreadNum->setText("5");
	}

	{
		QStringList headerText;
		headerText	<< ZN_STR("ID") << ZN_STR("�ǳ�")
					<< ZN_STR("״̬") << ZN_STR("����Ͷע");

		RobotTVModel* model = new RobotTVModel(headerText, RMGR->getRobotVector(), ui.tvlist);
		{
			QObject::connect(RMGR, SIGNAL(onRefreshModel()), model, SLOT(onRefreshModel()));

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
		QAction *onlineAct = new QAction(QStringLiteral("����"), m_menu);
		QAction *offlineAct = new QAction(QStringLiteral("����"), m_menu);
		m_menu->addAction(onlineAct);
		m_menu->addAction(offlineAct);

		connect(onlineAct, SIGNAL(triggered()),this, SLOT(onOnline()));
		connect(offlineAct, SIGNAL(triggered()), this, SLOT(onOffline()));
		
		connect(ui.tvlist, SIGNAL(customContextMenuRequested(const QPoint&)),
				this, SLOT(slotShowContextMenu(const QPoint&)));

	}
}

void RobotDialog::onClickedPBtnSelFilePath()
{
	QString strFilePath = QFileDialog::getOpenFileName(this, ZN_STR("ѡ���û������ļ�"), QCoreApplication::applicationDirPath(), 
														ZN_STR("Text files (*.txt);;All files (*.*)"));
	if (!strFilePath.isEmpty())
	{
		ui.ledtFilePath->setText(strFilePath);
	}
}

void RobotDialog::onClickedPBtnStartup()
{
	ui.pbtnStartup->setEnabled(false);
	{
		if (!m_bStartup)
		{
			if (ui.rbAutoGen->isChecked())
			{
				QString strHost = ui.ledtHostName->text();
				int port = ui.ledtPort->text().toInt();
				int nThreadNum = ui.ledtThreadNum->text().toInt();

				QString strPrefix = ui.ledtNamePrefix->text();
				int nRbtNum = ui.ledtRobotNum->text().toInt();

				RMGR->toDoWork(strHost, port, nThreadNum, strPrefix, nRbtNum);

				m_nThreadNum = nThreadNum;

				m_bStartup = true;
			}

			ui.pbtnStartup->setText(m_bStartup ? ZN_STR("ֹͣ") : ZN_STR("����"));
			ui.pbtnStartup->setEnabled(true);
		}
		else
		{
			RMGR->setResetFlag(true);

			m_bStartup = false;

			ui.pbtnStartup->setText(ZN_STR("����ֹͣ������,���Ժ�..."));
		}
	}
}

void RobotDialog::onOnline()
{

}

void RobotDialog::onOffline()
{

}

void RobotDialog::slotShowContextMenu(const QPoint& point)
{
	QModelIndex index = ui.tvlist->indexAt(point);
	if (index.isValid())
	{
		m_menu->exec(QCursor::pos());
	}
}

void RobotDialog::slotRobotTaskQuit()
{
	if (++m_nCurThreadNum >= m_nThreadNum)
	{
		ui.pbtnStartup->setEnabled(true);
		ui.pbtnStartup->setText(m_bStartup ? ZN_STR("ֹͣ") : ZN_STR("����"));

		m_nCurThreadNum = 0;
	}
}

