#include "BridgeWidget.h"

#include "QuerybackAndCheckWidget.h"

#include <QTabWidget>
#include <QHBoxLayout>
#include <QSplitter>


BridgeWidget::BridgeWidget(QWidget *parent)
	: QWidget(parent)
{
	{
		//resize(1065, 693);

		QSplitter *splitterMain = new QSplitter(Qt::Horizontal, 0);

		horizontalLayout = new QHBoxLayout(this);
		horizontalLayout->setSpacing(6);
		horizontalLayout->setContentsMargins(11, 11, 11, 11);
		horizontalLayout->setObjectName(QString::fromUtf8("horizontalLayout"));
		horizontalLayout->setContentsMargins(0, 0, 0, 0);
		horizontalLayout->addWidget(splitterMain);

		tabWidget = new QTabWidget(splitterMain);
		tabWidget->setObjectName(QString::fromUtf8("tabWidget"));
		tabWidget->setTabShape(QTabWidget::Triangular);

		widget = new QuerybackAndCheckWidget(splitterMain);
		widget->setObjectName(QString::fromUtf8("widget"));

		tabWidget->setCurrentIndex(0);
	}
}

BridgeWidget::~BridgeWidget()
{
}

QTabWidget* BridgeWidget::getTabWidget()
{
	return tabWidget;
}
