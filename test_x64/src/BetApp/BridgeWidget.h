#pragma once

#include <QWidget>

class QuerybackAndCheckWidget;
class QHBoxLayout;
class QTabWidget;
class BridgeWidget : public QWidget
{
	Q_OBJECT

public:
	BridgeWidget(QWidget *parent = Q_NULLPTR);
	~BridgeWidget();

	QTabWidget* getTabWidget();

private:
	QHBoxLayout *				horizontalLayout;
	QTabWidget *				tabWidget;
	QWidget *					tab;
	QWidget *					tab_2;
	QuerybackAndCheckWidget *	widget;
};
