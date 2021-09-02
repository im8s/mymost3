#include "GameRuleWidget.h"

#include "BetApplication.h"
#include "BetCtlManager.h"

#include "LotteryRule.h"


GameRuleWidget::GameRuleWidget(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);

	initUIByData();
}

GameRuleWidget::~GameRuleWidget()
{
}

void GameRuleWidget::initUIByData()
{
#ifdef USE_CONTAINER
	const LotteryRule* lr = BCMGR->getLotteryRule();
	if (lr)
	{
		{
			const tLotQuota& lq = lr->getLotteryQuata();

			{
				const tQuota& q = lq.qcoll[0];

				ui.cbMinAllQuota->setChecked(q.bUseThis);
				ui.ledtMinAllQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[1];

				ui.cbMaxSDQuota->setChecked(q.bUseThis);
				ui.ledtMaxSDQuota->setText(QString::number(q.nAmount));

				ui.cbUseSDGross->setChecked(lq.bUseSDGross);
			}

			{
				const tQuota& q = lq.qcoll[2];

				ui.cbMaxBSOEQuota->setChecked(q.bUseThis);
				ui.ledtMaxBSOEQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[3];

				ui.cbMaxGrpQuota->setChecked(q.bUseThis);
				ui.ledtMaxGrpQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[4];

				ui.cbMaxMMQuota->setChecked(q.bUseThis);
				ui.ledtMaxMMQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[5];

				ui.cbMax3SameQuota->setChecked(q.bUseThis);
				ui.ledtMax3SameQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[6];

				ui.cbMax2SameQuota->setChecked(q.bUseThis);
				ui.ledtMax2SameQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[7];

				ui.cbMaxContQuota->setChecked(q.bUseThis);
				ui.ledtMaxContQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.qcoll[8];

				ui.cbMaxAllQuota->setChecked(q.bUseThis);
				ui.ledtMaxAllQuota->setText(QString::number(q.nAmount));
			}
		}

		{
			const tLotForbid& lf = lr->getLotteryForbid();

			{
				const tForbid& f = lf.fcoll[0];

				ui.gbKillGrpForbid->setChecked(f.bUseForbid);

				ui.cbKillGrpForbid->setChecked(f.bUseThis);
				ui.ledtKillGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.fcoll[1];

				ui.gbReverseGrpForbid->setChecked(f.bUseForbid);

				ui.cbReverseGrpForbid->setChecked(f.bUseThis);
				ui.ledtReverseGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.fcoll[2];

				ui.gbSyntropyGrpForbid->setChecked(f.bUseForbid);

				ui.cbSyntropyGrpForbid->setChecked(f.bUseThis);
				ui.ledtSyntropyGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.fcoll[3];

				ui.gbBSOEGrpForbid->setChecked(f.bUseForbid);

				ui.cbBSOEGrpForbid->setChecked(f.bUseThis);
				ui.ledtBSOEGrpForbid->setText(QString::number(f.nAmount));
			}
		}

		{
			bool bUseSDLimit = lr->getSDLimit();
			int nMaxSDDiffNum = lr->getMaxSDDiffNum();

			ui.cbSDLimit->setChecked(bUseSDLimit);
			ui.ledtMaxSDDiffNum->setText(QString::number(nMaxSDDiffNum));

			bool bHintInvalid = lr->getHintInvalid();
			bool bSaveScreenshot = lr->getSaveScreenshot();

			ui.gbHintInvalid->setChecked(bHintInvalid);
			ui.cbSaveScreenshot->setChecked(bSaveScreenshot);
		}
	}
#else
	const LotteryRule* lr = BCMGR.getLotteryRule();
	if (lr)
	{
		{
			const tLotQuota& lq = lr->getLotteryQuata();

			{
				const tQuota& q = lq.minAllQuota;

				ui.cbMinAllQuota->setChecked(q.bUseThis);
				ui.ledtMinAllQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.maxSDQuota;

				ui.cbMaxSDQuota->setChecked(q.bUseThis);
				ui.ledtMaxSDQuota->setText(QString::number(q.nAmount));

				ui.cbUseSDGross->setChecked(lq.bUseSDGross);
			}

			{
				const tQuota& q = lq.maxBSOEQuota;

				ui.cbMaxBSOEQuota->setChecked(q.bUseThis);
				ui.ledtMaxBSOEQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.maxGrpQuota;

				ui.cbMaxGrpQuota->setChecked(q.bUseThis);
				ui.ledtMaxGrpQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.maxMMQuota;

				ui.cbMaxMMQuota->setChecked(q.bUseThis);
				ui.ledtMaxMMQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.max3SameQuota;

				ui.cbMax3SameQuota->setChecked(q.bUseThis);
				ui.ledtMax3SameQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.max2SameQuota;

				ui.cbMax2SameQuota->setChecked(q.bUseThis);
				ui.ledtMax2SameQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.maxContQuota;

				ui.cbMaxContQuota->setChecked(q.bUseThis);
				ui.ledtMaxContQuota->setText(QString::number(q.nAmount));
			}

			{
				const tQuota& q = lq.maxAllQuota;

				ui.cbMaxAllQuota->setChecked(q.bUseThis);
				ui.ledtMaxAllQuota->setText(QString::number(q.nAmount));
			}
		}

		{
			const tLotForbid& lf = lr->getLotteryForbid();

			{
				const tForbid& f = lf.killGrpForbid;

				ui.gbKillGrpForbid->setChecked(f.bUseForbid);

				ui.cbKillGrpForbid->setChecked(f.bUseThis);
				ui.ledtKillGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.reverseGrpForbid;

				ui.gbReverseGrpForbid->setChecked(f.bUseForbid);

				ui.cbReverseGrpForbid->setChecked(f.bUseThis);
				ui.ledtReverseGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.syntropyGrpForbid;

				ui.gbSyntropyGrpForbid->setChecked(f.bUseForbid);

				ui.cbSyntropyGrpForbid->setChecked(f.bUseThis);
				ui.ledtSyntropyGrpForbid->setText(QString::number(f.nAmount));
			}

			{
				const tForbid& f = lf.reverseBSOEForbid;

				ui.gbBSOEGrpForbid->setChecked(f.bUseForbid);

				ui.cbBSOEGrpForbid->setChecked(f.bUseThis);
				ui.ledtBSOEGrpForbid->setText(QString::number(f.nAmount));
			}
		}

		{
			bool bUseSDLimit = lr->getSDLimit();
			int nMaxSDDiffNum = lr->getMaxSDDiffNum();

			ui.cbSDLimit->setChecked(bUseSDLimit);
			ui.ledtMaxSDDiffNum->setText(QString::number(nMaxSDDiffNum));

			bool bHintInvalid = lr->getHintInvalid();
			bool bSaveScreenshot = lr->getSaveScreenshot();

			ui.gbHintInvalid->setChecked(bHintInvalid);
			ui.cbSaveScreenshot->setChecked(bSaveScreenshot);
		}
	}
#endif
}

bool GameRuleWidget::getDataFromUI(LotteryRule& lr)
{
#ifdef USE_CONTAINER
	{
		tLotQuota& lq = lr.getLotteryQuata();

		{
			tQuota& q = lq.qcoll[0];

			q.bUseThis = ui.cbMinAllQuota->isChecked();
			q.nAmount = ui.ledtMinAllQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[1];

			q.bUseThis = ui.cbMaxSDQuota->isChecked();
			q.nAmount = ui.ledtMaxSDQuota->text().toInt();

			lq.bUseSDGross = ui.cbUseSDGross->isChecked();
		}

		{
			tQuota& q = lq.qcoll[2];

			q.bUseThis = ui.cbMaxBSOEQuota->isChecked();
			q.nAmount = ui.ledtMaxBSOEQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[3];

			q.bUseThis = ui.cbMaxGrpQuota->isChecked();
			q.nAmount = ui.ledtMaxGrpQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[4];

			q.bUseThis = ui.cbMaxMMQuota->isChecked();
			q.nAmount = ui.ledtMaxMMQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[5];

			q.bUseThis = ui.cbMax3SameQuota->isChecked();
			q.nAmount = ui.ledtMax3SameQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[6];

			q.bUseThis = ui.cbMax2SameQuota->isChecked();
			q.nAmount = ui.ledtMax2SameQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[7];

			q.bUseThis = ui.cbMaxContQuota->isChecked();
			q.nAmount = ui.ledtMaxContQuota->text().toInt();
		}

		{
			tQuota& q = lq.qcoll[8];

			q.bUseThis = ui.cbMaxAllQuota->isChecked();
			q.nAmount = ui.ledtMaxAllQuota->text().toInt();
		}
	}

	{
		tLotForbid& lf = lr.getLotteryForbid();

		{
			tForbid& f = lf.fcoll[0];

			f.bUseForbid = ui.gbKillGrpForbid->isChecked();

			f.bUseThis = ui.cbKillGrpForbid->isChecked();
			f.nAmount = ui.ledtKillGrpForbid->text().toInt();
		}

		{
			tForbid& f = lf.fcoll[1];

			f.bUseForbid = ui.gbReverseGrpForbid->isChecked();

			f.bUseThis = ui.cbReverseGrpForbid->isChecked();
			f.nAmount = ui.ledtReverseGrpForbid->text().toInt();
		}

		{
			tForbid& f = lf.fcoll[2];

			f.bUseForbid = ui.gbSyntropyGrpForbid->isChecked();

			f.bUseThis = ui.cbSyntropyGrpForbid->isChecked();
			f.nAmount = ui.ledtSyntropyGrpForbid->text().toInt();

		}

		{
			tForbid& f = lf.fcoll[3];

			f.bUseForbid = ui.gbBSOEGrpForbid->isChecked();

			f.bUseThis = ui.cbBSOEGrpForbid->isChecked();
			f.nAmount = ui.ledtBSOEGrpForbid->text().toInt();

		}
	}

	{
		bool bUseSDLimit = ui.cbSDLimit->isChecked();
		lr.setSDLimit(bUseSDLimit);

		int nMaxSDDiffNum = ui.ledtMaxSDDiffNum->text().toInt();
		lr.setMaxSDDiffNum(nMaxSDDiffNum);

		bool bHintInvalid = ui.gbHintInvalid->isChecked();
		lr.setHintInvalid(bHintInvalid);

		bool bSaveScreenshot = ui.cbSaveScreenshot->isChecked();
		lr.setSaveScreenshot(bSaveScreenshot);
	}
#else
	{
		tLotQuota& lq = lr.getLotteryQuata();

		{
			tQuota& q = lq.minAllQuota;

			q.bUseThis = ui.cbMinAllQuota->isChecked();
			q.nAmount = ui.ledtMinAllQuota->text().toInt();
		}

		{
			tQuota& q = lq.maxSDQuota;

			q.bUseThis = ui.cbMaxSDQuota->isChecked();
			q.nAmount = ui.ledtMaxSDQuota->text().toInt();

			lq.bUseSDGross = ui.cbUseSDGross->isChecked();
		}

		{
			tQuota& q = lq.maxBSOEQuota;

			q.bUseThis = ui.cbMaxBSOEQuota->isChecked();
			q.nAmount = ui.ledtMaxBSOEQuota->text().toInt();
		}

		{
			tQuota& q = lq.maxGrpQuota;

			q.bUseThis = ui.cbMaxGrpQuota->isChecked();
			q.nAmount = ui.ledtMaxGrpQuota->text().toInt();
		}

		{
			tQuota& q = lq.maxMMQuota;

			q.bUseThis = ui.cbMaxMMQuota->isChecked();
			q.nAmount = ui.ledtMaxMMQuota->text().toInt();
		}

		{
			tQuota& q = lq.max3SameQuota;

			q.bUseThis = ui.cbMax3SameQuota->isChecked();
			q.nAmount = ui.ledtMax3SameQuota->text().toInt();
		}

		{
			tQuota& q = lq.max2SameQuota;

			q.bUseThis = ui.cbMax2SameQuota->isChecked();
			q.nAmount = ui.ledtMax2SameQuota->text().toInt();
		}

		{
			tQuota& q = lq.maxContQuota;

			q.bUseThis = ui.cbMaxContQuota->isChecked();
			q.nAmount = ui.ledtMaxContQuota->text().toInt();
		}

		{
			tQuota& q = lq.maxAllQuota;

			q.bUseThis = ui.cbMaxAllQuota->isChecked();
			q.nAmount = ui.ledtMaxAllQuota->text().toInt();
		}
	}

	{
		tLotForbid& lf = lr.getLotteryForbid();

		{
			tForbid& f = lf.killGrpForbid;

			f.bUseForbid = ui.gbKillGrpForbid->isChecked();

			f.bUseThis = ui.cbKillGrpForbid->isChecked();
			f.nAmount = ui.ledtKillGrpForbid->text().toInt();
		}

		{
			tForbid& f = lf.reverseGrpForbid;

			f.bUseForbid = ui.gbReverseGrpForbid->isChecked();

			f.bUseThis = ui.cbReverseGrpForbid->isChecked();
			f.nAmount = ui.ledtReverseGrpForbid->text().toInt();
		}

		{
			tForbid& f = lf.syntropyGrpForbid;

			f.bUseForbid = ui.gbSyntropyGrpForbid->isChecked();

			f.bUseThis = ui.cbSyntropyGrpForbid->isChecked();
			f.nAmount = ui.ledtSyntropyGrpForbid->text().toInt();

		}

		{
			tForbid& f = lf.reverseBSOEForbid;

			f.bUseForbid = ui.gbBSOEGrpForbid->isChecked();

			f.bUseThis = ui.cbBSOEGrpForbid->isChecked();
			f.nAmount = ui.ledtBSOEGrpForbid->text().toInt();

		}
	}

	{
		bool bUseSDLimit = ui.cbSDLimit->isChecked();
		lr.setSDLimit(bUseSDLimit);

		int nMaxSDDiffNum = ui.ledtMaxSDDiffNum->text().toInt();
		lr.setMaxSDDiffNum(nMaxSDDiffNum);

		bool bHintInvalid = ui.gbHintInvalid->isChecked();
		lr.setHintInvalid(bHintInvalid);

		bool bSaveScreenshot = ui.cbSaveScreenshot->isChecked();
		lr.setSaveScreenshot(bSaveScreenshot);
	}
#endif

	return true;
}


