#include "LostrateWidget.h"
#include "ToolFunc.h"

#include "LRSettings.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include <QMessageBox>


LostrateWidget::LostrateWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	{
		QObject::connect(ui.cbUseLCLikeCard1, SIGNAL(stateChanged(int)), this, SLOT(onCBStateChangedUseLCLikeCard1(int)));
		QObject::connect(ui.cbUseLCLikeCard2, SIGNAL(stateChanged(int)), this, SLOT(onCBStateChangedUseLCLikeCard2(int)));
		QObject::connect(ui.cbUseLCLikeCard3, SIGNAL(stateChanged(int)), this, SLOT(onCBStateChangedUseLCLikeCard3(int)));

		QObject::connect(ui.pbtnCalculate, SIGNAL(clicked()), this, SLOT(onClickedPBtnCalculate()));
	}

	initUIByData();
}

LostrateWidget::~LostrateWidget()
{
}

void LostrateWidget::initUIByData()
{
	const LRSettings* lrs = BCMGR->getLRSettings();
	if (lrs)
	{
		bool b1 = false, b2 = false, b3 = false;
		{
			const LikeCardLR& lclr = lrs->getLikeCardLR();

			{
				const tLikeCardLRDef& def = lclr.m_lcColl[0];

				b1 = def.bUseThis;

				ui.cbUseLCLikeCard1->setChecked(def.bUseThis);
				ui.ledtLikeCardTimes1->setText(QString::number(def.fTimes, 'f', 1));
			}

			{
				const tLikeCardLRDef& def = lclr.m_lcColl[1];

				b2 = def.bUseThis;

				ui.cbUseLCLikeCard2->setChecked(def.bUseThis);
				ui.ledtLikeCardTimes2->setText(QString::number(def.fTimes, 'f', 1));
			}

			{
				const tLikeCardLRDef& def = lclr.m_lcColl[2];

				b3 = def.bUseThis;

				ui.cbUseLCLikeCard3->setChecked(def.bUseThis);
				ui.ledtLikeCardTimes3->setText(QString::number(def.fTimes, 'f', 1));
				ui.cbUseLikeCard890->setChecked(lclr.m_bUse890);
			}
		}

		{
			const SumDigitalLR& sdlr = lrs->getSumDigitalLR();

			bool b = sdlr.m_bUseAccordLR;

			ui.rbSDAccordLR->setChecked(b);
			ui.rbSDSingleLR->setChecked(!b);

			ui.ledtSDAccordLR->setText(QString::number(sdlr.m_fAccordLR, 'f', 1));
			ui.tedtSDSingleLR->setPlainText(sdlr.getLRString());
		}

		{
			const BigSmallAndOddEvenLR& bsoelr = lrs->getBigSmallAndOddEvenLR();

			ui.ledtBSOEAccordLR->setText(QString::number(bsoelr.m_fAccordLR, 'f', 1));

			{
				{
					const tGrossAnd1314LRDef& def = bsoelr.m_g1314Coll[0];

					ui.cbBSOEGross1->setChecked(def.bUseThis);
					ui.ledtBSOEGross1->setText(QString::number(def.nGross));
					ui.ledtBSOEGrossTimes1->setText(QString::number(def.fTimes, 'f', 1));
				}

				{
					const tGrossAnd1314LRDef& def = bsoelr.m_g1314Coll[1];

					ui.cbBSOEGross2->setChecked(def.bUseThis);
					ui.ledtBSOEGross2->setText(QString::number(def.nGross));
					ui.ledtBSOEGrossTimes2->setText(QString::number(def.fTimes, 'f', 1));
				}

				{
					const tGrossAnd1314LRDef& def = bsoelr.m_g1314Coll[2];

					ui.cbBSOEGross3->setChecked(def.bUseThis);
					ui.ledtBSOEGross3->setText(QString::number(def.nGross));
					ui.ledtBSOEGrossTimes3->setText(QString::number(def.fTimes, 'f', 1));
				}
			}

			{
				{
					const tLikeCardLRDef& def = bsoelr.m_lcColl[0];

					ui.cbBSOELikeCard1->setChecked(def.bUseThis && b1);
					ui.ledtBSOELikeCardTimes1->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbBSOELikeCard1->setEnabled(b1);
						ui.ledtBSOELikeCardTimes1->setEnabled(b1);
					}
				}

				{
					const tLikeCardLRDef& def = bsoelr.m_lcColl[1];

					ui.cbBSOELikeCard2->setChecked(def.bUseThis && b2);
					ui.ledtBSOELikeCardTimes2->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbBSOELikeCard2->setEnabled(b2);
						ui.ledtBSOELikeCardTimes2->setEnabled(b2);
					}
				}

				{
					const tLikeCardLRDef& def = bsoelr.m_lcColl[2];

					ui.cbBSOELikeCard3->setChecked(def.bUseThis && b3);
					ui.ledtBSOELikeCardTimes3->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbBSOELikeCard3->setEnabled(b3);
						ui.ledtBSOELikeCardTimes3->setEnabled(b3);
					}
				}
			}

		}

		{
			const GroupByLR& grplr = lrs->getGroupByLR();

			bool b = grplr.m_bUseAlg1;

			ui.rbAlg1->setChecked(b);
			ui.rbAlg2->setChecked(!b);

			ui.ledtGrpAccordLR->setText(QString::number(grplr.m_fAccordLR, 'f', 1));

			ui.cbUseGrp1314LR->setChecked(grplr.m_bUse1314LR);
			ui.ledtGrp1314LR->setText(QString::number(grplr.m_f1314LR, 'f', 1));

			ui.ledtGrpBESOLR->setText(QString::number(grplr.m_fBigEvenAndSmallOddLR, 'f', 1));
			ui.ledtGrpSEBOLR->setText(QString::number(grplr.m_fSmallEvenAndBigOddLR, 'f', 1));

			{
				{
					const tGrossAnd1314LRDef& def = grplr.m_g1314Coll[0];

					ui.cbUseGrpGross1->setChecked(def.bUseThis);
					ui.ledtGrpGross1->setText(QString::number(def.nGross));
					ui.ledtGrpGrossTimes1->setText(QString::number(def.fTimes, 'f', 1));
				}

				{
					const tGrossAnd1314LRDef& def = grplr.m_g1314Coll[1];

					ui.cbUseGrpGross2->setChecked(def.bUseThis);
					ui.ledtGrpGross2->setText(QString::number(def.nGross));
					ui.ledtGrpGrossTimes2->setText(QString::number(def.fTimes, 'f', 1));
				}

				{
					const tGrossAnd1314LRDef& def = grplr.m_g1314Coll[2];

					ui.cbUseGrpGross3->setChecked(def.bUseThis);
					ui.ledtGrpGross3->setText(QString::number(def.nGross));
					ui.ledtGrpGrossTimes3->setText(QString::number(def.fTimes, 'f', 1));
				}
			}

			{
				{
					const tLikeCardLRDef& def = grplr.m_lcColl[0];

					ui.cbUseGrpLikeCard1->setChecked(def.bUseThis && b1);
					ui.ledtGrpLikeCardTimes1->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbUseGrpLikeCard1->setEnabled(b1);
						ui.ledtGrpLikeCardTimes1->setEnabled(b1);
					}
				}

				{
					const tLikeCardLRDef& def = grplr.m_lcColl[1];

					ui.cbUseGrpLikeCard2->setChecked(def.bUseThis && b2);
					ui.ledtGrpLikeCardTimes2->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbUseGrpLikeCard2->setEnabled(b2);
						ui.ledtGrpLikeCardTimes2->setEnabled(b2);
					}
				}

				{
					const tLikeCardLRDef& def = grplr.m_lcColl[2];

					ui.cbUseGrpLikeCard3->setChecked(def.bUseThis && b3);
					ui.ledtGrpLikeCardTimes3->setText(QString::number(def.fTimes, 'f', 1));

					{
						ui.cbUseGrpLikeCard3->setEnabled(b3);
						ui.ledtGrpLikeCardTimes3->setEnabled(b3);
					}
				}
			}

		}

		{
			const MinMaxByLR& mmlr = lrs->getMinMaxByLR();

			ui.ledtMMAccordLR->setText(QString::number(mmlr.m_fAccordLR, 'f', 1));
		}
	}
}

bool LostrateWidget::getDataFromUI(LRSettings& lrs)
{
	{
		SumDigitalLR& sdlr = lrs.getSumDigitalLR();

		sdlr.m_bUseAccordLR = ui.rbSDAccordLR->isChecked();

		sdlr.m_fAccordLR = ui.ledtSDAccordLR->text().toFloat();
		
		QString str = ui.tedtSDSingleLR->toPlainText();
		if (!sdlr.setLRString(str))
			return false;
	}

	{
		BigSmallAndOddEvenLR& bsoelr = lrs.getBigSmallAndOddEvenLR();

		bsoelr.m_fAccordLR = ui.ledtBSOEAccordLR->text().toFloat();

		{
			bsoelr.m_g1314Coll.clear();

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbBSOEGross1->isChecked();
				def.nGross = ui.ledtBSOEGross1->text().toInt();
				def.fTimes = ui.ledtBSOEGrossTimes1->text().toFloat();

				bsoelr.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbBSOEGross2->isChecked();
				def.nGross = ui.ledtBSOEGross2->text().toInt();
				def.fTimes = ui.ledtBSOEGrossTimes2->text().toFloat();

				bsoelr.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbBSOEGross3->isChecked();
				def.nGross = ui.ledtBSOEGross3->text().toInt();
				def.fTimes = ui.ledtBSOEGrossTimes3->text().toFloat();

				bsoelr.m_g1314Coll.append(def);
			}
		}

		{
			bsoelr.m_lcColl.clear();

			{
				tLikeCardLRDef def;
				
				def.nType = BST_3Same_Card;

				def.bUseThis = ui.cbBSOELikeCard1->isChecked();
				def.fTimes = ui.ledtBSOELikeCardTimes1->text().toFloat();

				bsoelr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_2Same_Card;

				def.bUseThis = ui.cbBSOELikeCard2->isChecked();
				def.fTimes = ui.ledtBSOELikeCardTimes2->text().toFloat();

				bsoelr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_Continuous_Card;

				def.bUseThis = ui.cbBSOELikeCard3->isChecked();
				def.fTimes = ui.ledtBSOELikeCardTimes3->text().toFloat();

				bsoelr.m_lcColl.append(def);
			}
		}
	}

	{
		GroupByLR& grplr = lrs.getGroupByLR();

		grplr.m_bUseAlg1 = ui.rbAlg1->isChecked();

		grplr.m_fAccordLR = ui.ledtGrpAccordLR->text().toFloat();

		grplr.m_bUse1314LR = ui.cbUseGrp1314LR->isChecked();
		grplr.m_f1314LR = ui.ledtGrp1314LR->text().toFloat();

		grplr.m_fBigEvenAndSmallOddLR = ui.ledtGrpBESOLR->text().toFloat();
		grplr.m_fSmallEvenAndBigOddLR = ui.ledtGrpSEBOLR->text().toFloat();

		{
			grplr.m_g1314Coll.clear();

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbUseGrpGross1->isChecked();
				def.nGross = ui.ledtGrpGross1->text().toInt();
				def.fTimes = ui.ledtGrpGrossTimes1->text().toFloat();

				grplr.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbUseGrpGross2->isChecked();
				def.nGross = ui.ledtGrpGross2->text().toInt();
				def.fTimes = ui.ledtGrpGrossTimes2->text().toFloat();

				grplr.m_g1314Coll.append(def);
			}

			{
				tGrossAnd1314LRDef def;

				def.bUseThis = ui.cbUseGrpGross3->isChecked();
				def.nGross = ui.ledtGrpGross3->text().toInt();
				def.fTimes = ui.ledtGrpGrossTimes3->text().toFloat();

				grplr.m_g1314Coll.append(def);
			}
		}

		{
			grplr.m_lcColl.clear();

			{
				tLikeCardLRDef def;

				def.nType = BST_3Same_Card;

				def.bUseThis = ui.cbUseGrpLikeCard1->isChecked();
				def.fTimes = ui.ledtGrpLikeCardTimes1->text().toFloat();

				grplr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_2Same_Card;

				def.bUseThis = ui.cbUseGrpLikeCard2->isChecked();
				def.fTimes = ui.ledtGrpLikeCardTimes2->text().toFloat();

				grplr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_Continuous_Card;

				def.bUseThis = ui.cbUseGrpLikeCard3->isChecked();
				def.fTimes = ui.ledtGrpLikeCardTimes3->text().toFloat();

				grplr.m_lcColl.append(def);
			}
		}
	}

	{
		MinMaxByLR& mmlr = lrs.getMinMaxByLR();

		mmlr.m_fAccordLR = ui.ledtMMAccordLR->text().toFloat();
	}

	{
		LikeCardLR& lclr = lrs.getLikeCardLR();

		lclr.m_bUse890 = ui.cbUseLikeCard890->isChecked();

		{
			lclr.m_lcColl.clear();

			{
				tLikeCardLRDef def;

				def.nType = BST_3Same_Card;

				def.bUseThis = ui.cbUseLCLikeCard1->isChecked();
				def.fTimes = ui.ledtLikeCardTimes1->text().toFloat();

				lclr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_2Same_Card;

				def.bUseThis = ui.cbUseLCLikeCard2->isChecked();
				def.fTimes = ui.ledtLikeCardTimes2->text().toFloat();

				lclr.m_lcColl.append(def);
			}

			{
				tLikeCardLRDef def;

				def.nType = BST_Continuous_Card;

				def.bUseThis = ui.cbUseLCLikeCard3->isChecked();
				def.fTimes = ui.ledtLikeCardTimes3->text().toFloat();

				lclr.m_lcColl.append(def);
			}
		}
	}

	return true;
}

void LostrateWidget::onCBStateChangedUseLCLikeCard1(int state)
{
	if (Qt::Checked != state)
	{
		{
			ui.cbBSOELikeCard1->setEnabled(false);
			ui.ledtBSOELikeCardTimes1->setEnabled(false);

			//ui.cbBSOELikeCard1->setChecked(false);
		}

		{
			ui.cbUseGrpLikeCard1->setEnabled(false);
			ui.ledtGrpLikeCardTimes1->setEnabled(false);

			//ui.cbUseGrpLikeCard1->setChecked(false);
		}
	}
	else
	{
		{
			ui.cbBSOELikeCard1->setEnabled(true);
			ui.ledtBSOELikeCardTimes1->setEnabled(true);
		}

		{
			ui.cbUseGrpLikeCard1->setEnabled(true);
			ui.ledtGrpLikeCardTimes1->setEnabled(true);
		}
	}
}

void LostrateWidget::onCBStateChangedUseLCLikeCard2(int state)
{
	if (Qt::Checked != state)
	{
		{
			ui.cbBSOELikeCard2->setEnabled(false);
			ui.ledtBSOELikeCardTimes2->setEnabled(false);

			//ui.cbBSOELikeCard2->setChecked(false);
		}

		{
			ui.cbUseGrpLikeCard2->setEnabled(false);
			ui.ledtGrpLikeCardTimes2->setEnabled(false);

			//ui.cbUseGrpLikeCard2->setChecked(false);
		}
	}
	else
	{
		{
			ui.cbBSOELikeCard2->setEnabled(true);
			ui.ledtBSOELikeCardTimes2->setEnabled(true);
		}

		{
			ui.cbUseGrpLikeCard2->setEnabled(true);
			ui.ledtGrpLikeCardTimes2->setEnabled(true);
		}
	}
}

void LostrateWidget::onCBStateChangedUseLCLikeCard3(int state)
{
	if (Qt::Checked != state)
	{
		{
			ui.cbBSOELikeCard3->setEnabled(false);
			ui.ledtBSOELikeCardTimes3->setEnabled(false);

			//ui.cbBSOELikeCard3->setChecked(false);
		}

		{
			ui.cbUseGrpLikeCard3->setEnabled(false);
			ui.ledtGrpLikeCardTimes3->setEnabled(false);

			//ui.cbUseGrpLikeCard3->setChecked(false);
		}
	}
	else
	{
		{
			ui.cbBSOELikeCard3->setEnabled(true);
			ui.ledtBSOELikeCardTimes3->setEnabled(true);
		}

		{
			ui.cbUseGrpLikeCard3->setEnabled(true);
			ui.ledtGrpLikeCardTimes3->setEnabled(true);
		}
	}
}

void LostrateWidget::onClickedPBtnCalculate()
{
	ui.pbtnCalculate->setEnabled(false);
	{
		QString strDig0 = ui.ledtDig0->text();
		QString strDig1 = ui.ledtDig1->text();
		QString strDig2 = ui.ledtDig2->text();

		tLottery lot;
		if (lot.addBetInfo(strDig0, strDig1, strDig2))
		{
			ui.lblResult->setText(lot.asResultFor());
		}
		else
		{
			QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("开奖号码输入错误"));
			return;
		}

		//////////////////////////////////////////////////////////////////////////////////

		tLotJudgeVector ljcoll;
		
		int flag = 0;
		int nTotalAmount = 0;

		QString strBetStr = ui.ledtBetString->text();
		QStringList strlst = strBetStr.split(' ', Qt::SkipEmptyParts);

		for (int k = 0; k < strlst.size(); ++k)
		{
			QString& strSubBetStr = strlst[k];

			tLotJudge lj;
			if (!lj.addBetInfo(0, "", strSubBetStr))
			{
				QMessageBox::information( this, ZN_STR("信息提示"), ZN_STR("投注无效,不能识别: %1").arg(strBetStr) );
				flag = 1;
				break;
			}

			QString strMsg;
			if (!BCMGR->checkRules(lj, strMsg))
			{
				QMessageBox::information(this, ZN_STR("信息提示"), strMsg);
				flag = 1;
				break;
			}

			nTotalAmount += lj.nAmount;

			ljcoll.append(lj);
		}

		if (0 == flag)
		{
			float fvTotal = 0;

			for (int i = 0; i < ljcoll.size(); ++i)
			{
				tLotJudge& lj = ljcoll[i];

				float fv = 0;
				if (!BCMGR->getWinLosPoint(lot, lj, nTotalAmount, fv))
				{
					QMessageBox::information(this, ZN_STR("信息提示"), ZN_STR("计算赔率错误"));
					flag = 1;
					break;
				}

				fvTotal += fv;
			}

			if(0 == flag)
				ui.ledtResult->setText(QString::number(fvTotal, 'f', 2));
		}
	}
	ui.pbtnCalculate->setEnabled(true);
}



