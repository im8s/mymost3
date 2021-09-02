#include "InfoSettingsWidget.h"

#include "ForNoGuessWidget.h"
#include "ForLotteryWidget.h"
#include "ForScoreWidget.h"
#include "ForAdvertiseWidget.h"
#include "ForTestWidget.h"


InfoSettingsWidget::InfoSettingsWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	{
		ui.tabWidget->clear();
		{
			ForNoGuessWidget* p = new ForNoGuessWidget();
			ui.tabWidget->addTab(p, p->windowTitle());
		}

		{
			ForLotteryWidget* p = new ForLotteryWidget();
			ui.tabWidget->addTab(p, p->windowTitle());
		}

		{
			ForScoreWidget* p = new ForScoreWidget();
			ui.tabWidget->addTab(p, p->windowTitle());
		}

		{
			ForAdvertiseWidget* p = new ForAdvertiseWidget();
			ui.tabWidget->addTab(p, p->windowTitle());
		}

		{
			ForTestWidget* p = new ForTestWidget();
			ui.tabWidget->addTab(p, p->windowTitle());
		}
	}
}

InfoSettingsWidget::~InfoSettingsWidget()
{
}
