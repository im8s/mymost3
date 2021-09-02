#pragma once

#include <QWidget>
//namespace Ui { class StatusWidget; };

class QHBoxLayout;
class QLabel;
class StatusWidget : public QWidget
{
	Q_OBJECT

public:
	StatusWidget(QWidget *parent = Q_NULLPTR);
	~StatusWidget();

	void setText(int flag, const QString& strMsg);

private:
	//Ui::StatusWidget *ui;

	QHBoxLayout *horizontalLayout_9;

	QLabel *lbl0;
	QLabel *lbl1;
	QLabel *lbl2;
	QLabel *lbl3;
	QLabel *lbl4;
};
